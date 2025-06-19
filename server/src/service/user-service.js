import bcrypt from 'bcryptjs'
import { v4 as uuidv4 } from 'uuid'
import { pool } from '../config/db.js'
import tokenService from './token-service.js'
import { ApiError } from '../exceptions/api-error.js'
import logger from '../config/logger.js'
import { UserDto } from '../dtos/user-dto.js'
import mailService from './mail-service.js'

class UserService {
	// async registration(email, password) {
	// 	try {
	// 		const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email])
	// 		if (userCheck.rows.length > 0) {
	// 			throw ApiError.BadRequest('Пользователь с таким email уже существует')
	// 		}
	// 		const hashedPassword = await bcrypt.hash(password, 10)
	// 		const userId = uuidv4()
	// 		const role = "admin"
	// 		await pool.query(
	// 			`INSERT INTO users (id, email, password, role) 
	//                    VALUES ($1, $2, $3, $4) RETURNING id, email, role`,
	// 			[userId, email, hashedPassword, role]
	// 		)
	// 		logger.info(`Пользователь успешно зарегистрирован: ${email}`)
	// 		return
	// 	} catch (error) {
	// 		logger.error(`Ошибка при регистрации: ${error.message}`)
	// 		throw error instanceof ApiError ? error : ApiError.InternalError()
	// 	}
	// }

	async registrationAdmin(users) {
		try {
			await pool.query('BEGIN')
			for (const user of users) {
				const { first_name, middle_name, last_name, group, role, email } = user
				const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email])
				if (userCheck.rows?.length) {
					throw ApiError.BadRequest(`Пользователь с email ${email} уже существует`)
				}
				let newPassword = ''
				const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
				for (let i = 0; i < 6; i++) {
					const randomIndex = Math.floor(Math.random() * chars.length)
					newPassword += chars[randomIndex]
				}
				const hashedPassword = await bcrypt.hash(newPassword, 10)
				const userId = uuidv4()
				await pool.query(
					`INSERT INTO users (id, email, password, role) 
                 VALUES ($1, $2, $3, $4)`,
					[userId, email, hashedPassword, role]
				)
				if (role === 'lecturer') {
					await pool.query(
						`INSERT INTO lecturers (user_id, first_name, middle_name, last_name) 
                     VALUES ($1, $2, $3, $4)`,
						[userId, first_name, middle_name, last_name]
					)
				} else if (role === 'student') {
					await pool.query(
						`INSERT INTO students (user_id, first_name, middle_name, last_name, group_id) 
                     VALUES ($1, $2, $3, $4, $5)`,
						[userId, first_name, middle_name, last_name, group]
					)
				}
				await mailService.sendInfoUser(email, email, newPassword)
			}
			logger.info(`Успешно добавлено ${users.length} пользователей`)
			await pool.query('COMMIT')
			return
		} catch (error) {
			logger.error(`Ошибка при регистрации пользователей: ${error.message}`)
			await pool.query('ROLLBACK')
			if (error instanceof ApiError) {
			throw error
			} else {
				throw ApiError.InternalError(error.message) 
			}
		}
	}

	async login(email, password, ipAddress, userAgent, uid) {
		try {
			logger.info(`Попытка входа: ${email}`)
			const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email])
			if (userResult.rows.length === 0) {
				throw ApiError.BadRequest('Пользователь не найден')
			}
			const user = userResult.rows[0]
			const isPassValid = await bcrypt.compare(password, user.password)
			if (!isPassValid) {
				throw ApiError.BadRequest('Неверный email или пароль')
			}
			const checkAuthResult = await pool.query(
				'SELECT * FROM tokens WHERE user_id = $1',
				[user.id]
			)
			const knownDevice = checkAuthResult.rows.find(row => row.unique_id === uid)
			if (checkAuthResult.rows.length && !knownDevice) {
				return { user_sub: user.id }
			}
			const userDto = new UserDto({ ...user, unique_id: uid })
			const tokens = tokenService.generateTokens(userDto)
			await tokenService.saveToken(uid, userDto.sub, tokens.refreshToken, ipAddress, userAgent, tokens.jti)
			logger.info(`Успешный вход пользователя: ${email}`)
			return { ...tokens, user: userDto }
		} catch (error) {
			logger.error(`Ошибка при входе: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async prepareNewDevice(userId, email) {
		try {
			logger.info(`Подтверждение нового устройства пользователя: ${userId}`)
			const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
			let code = ''
			for (let i = 0; i < 6; i++) {
				const randomIndex = Math.floor(Math.random() * chars.length)
				code += chars[randomIndex]
			}
			const tempToken = tokenService.generateTempToken(userId)
			await pool.query(`
			INSERT INTO temp_tokens (user_id, temp_token, code, expires_at)
			VALUES ($1, $2, $3, NOW() + INTERVAL '10 minutes')
			ON CONFLICT (user_id) 
			DO UPDATE SET temp_token = EXCLUDED.temp_token, code = EXCLUDED.code, expires_at = EXCLUDED.expires_at
		`, [userId, tempToken, code])
			mailService.sendNewDeviceCode(email, code)
			return tempToken
		} catch (error) {
			logger.error(`Ошибка при подтверждении нового устройства: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async confirmNewDevice(code, tempToken, uniqueId, userIp, userAgent) {
		try {
			const decodedTempToken = tokenService.validateTempToken(tempToken)
			const userId = decodedTempToken.sub
			const codeResult = await pool.query(
				'SELECT code FROM temp_tokens WHERE user_id = $1 AND temp_token = $2 AND expires_at > NOW()',
				[userId, tempToken]
			)
			if (!codeResult.rows.length || codeResult.rows[0].code !== code) {
				throw ApiError.NotFound('Неверный код подтверждения')
			}
			await pool.query('DELETE FROM temp_tokens WHERE user_id = $1', [userId])
			const user = await pool.query('SELECT * FROM users WHERE id = $1', [userId])
			const userData = tokenService.generateTokens({ sub: userId, role: user.rows[0].role, unique_id: uniqueId })
			await tokenService.saveToken(uniqueId, userId, userData.refreshToken, userIp, userAgent, userData.jti)
			userData.sub = userId
			userData.role = user.rows[0].role
			return userData
		} catch (error) {
			logger.error(`Ошибка при подтверждении нового устройства: ${error}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async changePassword(userId, currentPassword, newPassword) {
		try {
			logger.info(`Смена пароля для пользователя: ${userId}`)
			const user = await pool.query('SELECT * FROM users WHERE id = $1', [userId])
			const isPassValid = await bcrypt.compare(currentPassword, user.rows[0].password)
			if (!isPassValid) {
				throw ApiError.BadRequest('Текущий пароль неверный')
			}
			const hashedPassword = await bcrypt.hash(newPassword, 10)
			await pool.query(
				`UPDATE users SET password = $1 WHERE id = $2`,
				[hashedPassword, userId]
			)
			mailService.sendChangePassword(user.rows[0].email, user.rows[0].email, newPassword, false)
			logger.info(`Пароль успешно изменен для пользователя: ${userId}`)
			return
		} catch (error) {
			logger.error(`Ошибка при смене пароля: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async changeEmail(userId, currentEmail, newEmail) {
		try {
			logger.info(`Смена email для пользователя: ${userId}`)
			const user = await pool.query('SELECT * FROM users WHERE id = $1', [userId])
			if (user.rows[0].email !== currentEmail) {
				throw ApiError.BadRequest('Текущий email неверный',)
			}
			const existing = await pool.query('SELECT * FROM users WHERE email = $1', [newEmail])
			if (existing.rows.length > 0) {
				throw ApiError.BadRequest('Невозможно изменить email. Проверьте введённые данные.')
			}
			await pool.query(
				`UPDATE users SET email = $1 WHERE id = $2`,
				[newEmail, userId]
			)
			mailService.sendChangeEmail(currentEmail, newEmail, false)
			logger.info(`Email успешно изменён для пользователя: ${userId}`)
			return
		} catch (error) {
			logger.error(`Ошибка при смене email: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async refresh(refreshToken, ipAddress, userAgent) {
		try {
			logger.info('Попытка обновления токена')
			const userData = tokenService.validateRefreshToken(refreshToken)
			if (!userData) {
				throw ApiError.UnauthorizedError()
			}
			const tokenFromDb = await tokenService.findToken(refreshToken)
			if (!tokenFromDb) {
				return
			}
			const userResult = await pool.query('SELECT * FROM users WHERE id = $1', [userData.sub])
			const user = userResult.rows[0]
			const userDto = new UserDto({
				...user, unique_id: userData.unique_id, jti: tokenFromDb.id
			})
			const tokens = tokenService.generateTokens(userDto)
			await tokenService.saveToken(userDto.unique_id, userDto.sub, tokens.refreshToken, ipAddress, userAgent)
			logger.info(`Токен успешно обновлен для пользователя: ${userDto.sub}`)
			return { ...tokens, user: userDto }
		} catch (error) {
			logger.error(`Ошибка при обновлении токена: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.UnauthorizedError()
		}
	}

	async logout(refreshToken) {
		try {
			logger.info('Попытка выхода')
			await tokenService.removeToken(refreshToken)
			logger.info('Успешный выход')
		} catch (error) {
			logger.error(`Ошибка при выходе: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async getProfile(userId, role) {
		try {
			logger.info(`Получение профиля для пользователя: ${userId} с ролью: ${role}`)
			if (role === 'student') {
				const studentResult = await pool.query(`
					SELECT u.email, u.role,
								 s.first_name, s.middle_name, s.last_name,
								 g.name AS student_group_name
					FROM users u
					JOIN students s ON u.id = s.user_id
					LEFT JOIN groups g ON s.group_id = g.id
					WHERE u.id = $1
				`, [userId])
				const student = studentResult.rows[0]
				const subjectsResult = await pool.query(`
					SELECT DISTINCT subj.name
					FROM lab_submissions ls
					JOIN labs l ON ls.lab_id = l.id
					JOIN subjects subj ON l.subject_id = subj.id
					WHERE ls.student_id = $1
					ORDER BY subj.name
				`, [userId])
				const allSubjects = subjectsResult.rows
				const gradesResult = await pool.query(`
					SELECT subj.name AS subject, ls.grade
					FROM lab_submissions ls
					JOIN labs l ON ls.lab_id = l.id
					JOIN subjects subj ON l.subject_id = subj.id
					WHERE ls.student_id = $1
				`, [userId])
				const subjectGradesMap = {}
				gradesResult.rows.forEach(({ subject, grade }) => {
					if (grade !== null) {
						if (!subjectGradesMap[subject]) {
							subjectGradesMap[subject] = []
						}
						subjectGradesMap[subject].push(grade)
					}
				})
				const averageGrades = allSubjects.map(subject => {
					const grades = subjectGradesMap[subject.name]
					if (!grades || grades.length === 0) {
						return { subject: subject.name, grade: null }
					}
					const sum = grades.reduce((a, b) => a + b, 0)
					const avg = sum / grades.length
					return {
						subject: subject.name,
						grade: avg.toFixed(1)
					}
				})
				return {
					user: {
						email: student.email,
						first_name: student.first_name,
						middle_name: student.middle_name,
						last_name: student.last_name,
						group: student.student_group_name || null
					},
					averageGrades
				}
			}
			if (role === 'lecturer') {
				const lecturerResult = await pool.query(`
					SELECT u.email, u.role,
					l.first_name, l.middle_name, l.last_name
					FROM users u
					JOIN lecturers l ON u.id = l.user_id
					WHERE u.id = $1
				`, [userId])
				const lecturer = lecturerResult.rows[0]
				const availableSubjectsResult = await pool.query(`
					SELECT id, name FROM subjects ORDER BY name
				`)
				const selectedSubjectsResult = await pool.query(`
					SELECT subj.id, subj.name
					FROM lecturer_subjects ls
					JOIN subjects subj ON ls.subject_id = subj.id
					WHERE ls.lecturer_id = $1
					ORDER BY subj.name
				`, [userId])
				const availableGroupsResult = await pool.query(`
					SELECT id, name FROM groups ORDER BY name
				`)
				const selectedGroupsResult = await pool.query(`
					SELECT g.id, g.name
					FROM lecturer_groups lg
					JOIN groups g ON lg.group_id = g.id
					WHERE lg.lecturer_id = $1
					ORDER BY g.name
				`, [userId])
				return {
					user: {
						email: lecturer.email,
						first_name: lecturer.first_name,
						middle_name: lecturer.middle_name,
						last_name: lecturer.last_name
					},
					availableSubjects: availableSubjectsResult.rows,
					selectedSubjects: selectedSubjectsResult.rows,
					availableGroups: availableGroupsResult.rows,
					selectedGroups: selectedGroupsResult.rows
				}
			}
		} catch (error) {
			logger.error(`Ошибка при получении профиля пользователя: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}


	async getUsers() {
		try {
			logger.info('Получение списка всех пользователей')
			const users = await pool.query(`
				SELECT 
					u.id,
					u.email,
					u.role,
					-- Унифицированные ФИО в зависимости от роли
					CASE 
						WHEN u.role = 'student' THEN s.first_name
						WHEN u.role = 'lecturer' THEN l.first_name
						ELSE NULL
					END AS first_name,
					CASE 
						WHEN u.role = 'student' THEN s.middle_name
						WHEN u.role = 'lecturer' THEN l.middle_name
						ELSE NULL
					END AS middle_name,
					CASE 
						WHEN u.role = 'student' THEN s.last_name
						WHEN u.role = 'lecturer' THEN l.last_name
						ELSE NULL
					END AS last_name,
					g.name AS group_name
				FROM users u
				LEFT JOIN lecturers l ON u.id = l.user_id
				LEFT JOIN students s ON u.id = s.user_id
				LEFT JOIN groups g ON s.group_id = g.id
			`)
			logger.info('Список пользователей успешно получен')
			return users.rows
		} catch (error) {
			logger.error(`Ошибка при получении пользователей: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async searchUsers(query) {
		try {
			logger.info(`Поиск пользователей по запросу: ${query}`)
			const users = await pool.query(`
				SELECT 
					u.id,
					u.email,
					u.role,
					-- Унифицированные ФИО в зависимости от роли
					CASE 
						WHEN u.role = 'student' THEN s.first_name
						WHEN u.role = 'lecturer' THEN l.first_name
						ELSE NULL
					END AS first_name,
					CASE 
						WHEN u.role = 'student' THEN s.middle_name
						WHEN u.role = 'lecturer' THEN l.middle_name
						ELSE NULL
					END AS middle_name,
					CASE 
						WHEN u.role = 'student' THEN s.last_name
						WHEN u.role = 'lecturer' THEN l.last_name
						ELSE NULL
					END AS last_name,
					g.name AS group_name
				FROM users u
				LEFT JOIN lecturers l ON u.id = l.user_id
				LEFT JOIN students s ON u.id = s.user_id
				LEFT JOIN groups g ON s.group_id = g.id
				WHERE 
					u.email ILIKE $1 OR 
					s.first_name ILIKE $1 OR s.last_name ILIKE $1 OR s.middle_name ILIKE $1 OR
					l.first_name ILIKE $1 OR l.last_name ILIKE $1 OR l.middle_name ILIKE $1
			`, [`%${query}%`])
			logger.info(`Найдено ${users.rows.length} пользователей`)
			return users.rows
		} catch (error) {
			logger.error(`Ошибка при поиске пользователей: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async updateUser(id, userData, myId) {
		try {
			logger.info(`Обновление пользователя: ${id}`)
			await pool.query('BEGIN')
			const updates = []
			const values = []
			let index = 1
			let newPassword = null
			const currentUser = await pool.query('SELECT role,email FROM users WHERE id = $1', [id])
			const role = currentUser.rows[0].role
			if (myId != id && role == 'admin') {
				throw ApiError.BadRequest('Нельзя изменить данные у admin')
			}
			if (userData.resetPassword) {
				newPassword = ''
				const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
				for (let i = 0; i < 6; i++) {
					const randomIndex = Math.floor(Math.random() * chars.length)
					newPassword += chars[randomIndex]
				}
				const hashedPassword = await bcrypt.hash(newPassword, 10)
				updates.push(`password = $${index++}`)
				values.push(hashedPassword)
			}
			if (userData.email) {
				updates.push(`email = $${index++}`)
				values.push(userData.email)
			}
			if (updates.length > 0) {
				values.push(id)
				await pool.query(
					`UPDATE users SET ${updates.join(', ')} WHERE id = $${index}`,
					values
				)
			}
			if (role === 'lecturer') {
				const lecturerUpdates = []
				const lecturerValues = []
				let lecturerIndex = 1
				if (userData.first_name) {
					lecturerUpdates.push(`first_name = $${lecturerIndex++}`)
					lecturerValues.push(userData.first_name)
				}
				if (userData.middle_name) {
					lecturerUpdates.push(`middle_name = $${lecturerIndex++}`)
					lecturerValues.push(userData.middle_name)
				}
				if (userData.last_name) {
					lecturerUpdates.push(`last_name = $${lecturerIndex++}`)
					lecturerValues.push(userData.last_name)
				}
				if (lecturerUpdates.length > 0) {
					lecturerValues.push(id)
					await pool.query(
						`UPDATE lecturers SET ${lecturerUpdates.join(', ')} WHERE user_id = $${lecturerIndex}`,
						lecturerValues
					)
				}
			}
			else if (role === 'student') {
				const studentUpdates = []
				const studentValues = []
				let studentIndex = 1
				if (userData.first_name) {
					studentUpdates.push(`first_name = $${studentIndex++}`)
					studentValues.push(userData.first_name)
				}
				if (userData.middle_name) {
					studentUpdates.push(`middle_name = $${studentIndex++}`)
					studentValues.push(userData.middle_name)
				}
				if (userData.last_name) {
					studentUpdates.push(`last_name = $${studentIndex++}`)
					studentValues.push(userData.last_name)
				}
				if (userData.group_name) {
					const groupRes = await pool.query('SELECT id FROM groups WHERE name = $1', [userData.group_name])
					if (!groupRes || groupRes.rowCount === 0) {
						throw ApiError.BadRequest(`Группа с названием "${userData.group_name}" не найдена`)
					}
					studentUpdates.push(`group_id = $${studentIndex++}`)
					studentValues.push(groupRes.rows[0].id)
				}
				if (studentUpdates.length > 0) {
					studentValues.push(id)
					await pool.query(
						`UPDATE students SET ${studentUpdates.join(', ')} WHERE user_id = $${studentIndex}`,
						studentValues
					)
				}
			}
			await pool.query('COMMIT')
			if (newPassword) {
				mailService.sendChangePassword(userData?.email || currentUser?.rows[0]?.email, userData.email || currentUser?.rows[0]?.email, newPassword, true)
			}
			if (userData.email) {
				mailService.sendChangeEmail(currentUser.rows[0].email, userData.email, true)
			}
			logger.info(`Пользователь успешно обновлён: ${id}`)
			return
		} catch (error) {
			await pool.query('ROLLBACK')
			logger.error(`Ошибка при обновлении пользователя: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async deleteUser(id) {
		try {
			logger.info(`Удаление пользователя: ${id}`)
			await pool.query('DELETE FROM users WHERE id = $1', [id])
			logger.info(`Пользователь успешно удален: ${id}`)
			return
		} catch (error) {
			logger.error(`Ошибка при удалении пользователя: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async updateSubjects(userId, subjects) {
		try {
			logger.info(`Обновление предметов для пользователя: ${userId}`)
			await pool.query('BEGIN')
			await pool.query('DELETE FROM lecturer_subjects WHERE lecturer_id = $1', [userId])
			for (const subjectId of subjects) {
				const subjectCheck = await pool.query('SELECT id FROM subjects WHERE id = $1', [subjectId])
				if (subjectCheck?.rows?.length === 0) {
					throw ApiError.BadRequest(`Предмет с ID ${subjectId} не найден`)
				}
				await pool.query(
					`INSERT INTO lecturer_subjects (lecturer_id, subject_id) 
                 VALUES ($1, $2)`,
					[userId, subjectId]
				)
			}
			await pool.query('COMMIT')
			logger.info(`Предметы успешно обновлены для пользователя: ${userId}`)
			return
		} catch (error) {
			await pool.query('ROLLBACK')
			logger.error(`Ошибка при обновлении предметов: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async updateGroups(userId, groups) {
		logger.info(`Обновление групп для пользователя: ${userId}`)
		try {
			await pool.query('BEGIN')
			await pool.query('DELETE FROM lecturer_groups WHERE lecturer_id = $1', [userId])
			for (const groupId of groups) {
				const groupCheck = await pool.query('SELECT id FROM groups WHERE id = $1', [groupId])
				if (groupCheck.rows.length === 0) {
					throw ApiError.BadRequest(`Группа с ID ${groupId} не найдена`)
				}
				await pool.query(
					`INSERT INTO lecturer_groups (lecturer_id, group_id) 
                 VALUES ($1, $2)`,
					[userId, groupId]
				)
			}
			await pool.query('COMMIT')
			logger.info(`Группы успешно обновлены для пользователя: ${userId}`)
			return
		} catch (error) {
			await pool.query('ROLLBACK')
			logger.error(`Ошибка при обновлении групп: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async quitSessions(userId) {
		try {
			await pool.query(
				`UPDATE tokens SET is_revoked = TRUE WHERE user_id = $1`,
				[userId]
			)
			logger.info(`Все сессии пользователя с id ${userId} завершены.`)
			return
		} catch (error) {
			logger.error(`Ошибка при завершении сессий: ${error.message}`)
			throw ApiError.InternalError()
		}
	}
}

export default new UserService()
