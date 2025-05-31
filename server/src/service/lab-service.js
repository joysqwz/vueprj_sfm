import { pool, query } from '../config/db.js'
import { ApiError } from '../exceptions/api-error.js'
import { v4 as uuidv4 } from 'uuid'
import logger from '../config/logger.js'
import fs from 'fs'
import fsp from 'fs/promises'
import path from 'path'
import { fileURLToPath } from 'url'

class LabService {
	async createLab(lecturerId, title, groupIds, description, fileNames, filePaths, subjectId) {
		logger.info(`Добавление ЛБ преподавателем: ${lecturerId}`)
		try {
			const labId = uuidv4()
			const labResult = await pool.query(
				`INSERT INTO labs (id, lecturer_id, title, description, subject_id, created) 
				 VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP) RETURNING id, created`,
				[labId, lecturerId, title, description, subjectId]
			)
			const lab = labResult.rows[0]
			for (let i = 0; i < fileNames.length; i++) {
				const fileId = uuidv4()
				await pool.query(
					`INSERT INTO lab_files (id, lab_id, file_name, file_path) 
					 VALUES ($1, $2, $3, $4)`,
					[fileId, labId, fileNames[i], filePaths[i]]
				)
			}
			const groupIdsArray = Array.isArray(groupIds) ? groupIds : [groupIds]
			for (const groupId of groupIdsArray) {
				await pool.query(
					`INSERT INTO lab_groups (lab_id, group_id) 
					 VALUES ($1, $2)`,
					[labId, groupId]
				)
			}
			const studentsResult = await pool.query(
				`SELECT s.user_id 
				 FROM students s 
				 WHERE s.group_id = ANY($1::uuid[])`,
				[groupIdsArray]
			)
			const students = studentsResult.rows
			for (const student of students) {
				const submissionId = uuidv4()
				await pool.query(
					`INSERT INTO lab_submissions (id, lab_id, student_id, submitted_at) 
					 VALUES ($1, $2, $3, NULL)`,
					[submissionId, labId, student.user_id]
				)
			}
			logger.info(`Лабораторная работа создана: ${labId}`)
			return { id: lab.id, created: lab.created.toISOString().split('T')[0] }
		} catch (error) {
			logger.error(`Ошибка при создании ЛБ: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async getLabsByUser(userId, userRole) {
		try {
			logger.info(`Получение лабораторных работ для пользователя ${userId} с ролью ${userRole}`)
			let labsResult
			if (userRole === 'lecturer') {
				labsResult = await query(
					`
					SELECT 
						l.id,
						l.title,
						l.description,
						l.created,
						s.name AS subject,
						ARRAY_AGG(g.name ORDER BY g.name) AS lab_group
					FROM labs l
					LEFT JOIN subjects s ON l.subject_id = s.id
					LEFT JOIN lab_groups lg ON lg.lab_id = l.id
					LEFT JOIN groups g ON g.id = lg.group_id
					WHERE l.lecturer_id = $1
					GROUP BY l.id, s.name
					`,
					[userId]
				)
			} else if (userRole === 'student') {
				labsResult = await pool.query(
					`
					SELECT 
						ls.lab_id AS id, 
						l.title, 
						l.description, 
						ls.grade, 
						l.created, 
						s.name AS subject
					FROM lab_submissions ls
					JOIN labs l ON ls.lab_id = l.id
					LEFT JOIN subjects s ON l.subject_id = s.id
					WHERE ls.student_id = $1
					`,
					[userId]
				)
			} else {
				logger.warn(`Неизвестная роль пользователя: ${userRole}`)
				return []
			}
			const labs = labsResult.rows
				.sort((a, b) => new Date(b.created) - new Date(a.created))
				.map(row => {
					const base = {
						id: row.id,
						title: row.title,
						subject: row.subject,
						description: row.description,
						created: row.created.toISOString().split('T')[0]
					}

					if (userRole === 'lecturer') {
						return { ...base, lab_group: row.lab_group }
					} else if (userRole === 'student') {
						return { ...base, grade: row.grade !== undefined ? row.grade : null }
					}

					return base
				})
			labs.sort((a, b) => new Date(b.created) - new Date(a.created))
			logger.info(`Успешно получены лабораторные работы (${labs.length} записей)`)
			return labs
		} catch (error) {
			logger.error(`Ошибка при получении лабораторных работ: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async getLabDetails(labId, userId, userRole) {
		try {
			logger.info(`Получение подробностей лабораторной работы: ${labId}`)
			const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
			if (!uuidRegex.test(labId)) {
				logger.warn(`Некорректный UUID: ${labId}`)
				throw ApiError.BadRequest('Неверный ID лабораторной работы')
			}
			let accessCheck = ''
			let params = [labId]
			if (userRole === 'lecturer') {
				accessCheck = 'AND l.lecturer_id = $2'
				params.push(userId)
			} else if (userRole === 'student') {
				accessCheck = `
					AND EXISTS (
						SELECT 1
						FROM lab_groups lg
						JOIN students s ON s.group_id = lg.group_id
						WHERE lg.lab_id = l.id AND s.user_id = $2
					)
				`
				params.push(userId)
			}
			const labResult = await pool.query(
				`
				SELECT 
					l.id, 
					l.title, 
					l.description, 
					l.created AS created_at,
					s.name AS subject_name,
					ls.grade
				FROM labs l
				LEFT JOIN subjects s ON l.subject_id = s.id
				LEFT JOIN lab_submissions ls ON ls.lab_id = l.id AND ls.student_id = $${params.length}
				WHERE l.id = $1
				${accessCheck}
				`,
				params
			)
			if (labResult.rows.length === 0) {
				logger.warn(`Лабораторная работа с ID ${labId} не найдена или доступ запрещён`)
				return null
			}
			const lab = labResult.rows[0]
			const filesResult = await pool.query(
				`SELECT id, file_name FROM lab_files WHERE lab_id = $1`,
				[labId]
			)
			lab.files = filesResult.rows
			const groupsResult = await pool.query(
				`
				SELECT g.name 
				FROM lab_groups lg
				JOIN groups g ON g.id = lg.group_id
				WHERE lg.lab_id = $1
				`,
				[labId]
			)
			lab.groups = groupsResult.rows.sort((a, b) => a.name.localeCompare(b.name))
			lab.created_at = lab.created_at.toISOString().split('T')[0]
			if (userRole === 'student') {
				lab.grade = lab.grade !== undefined ? lab.grade : null
			}
			logger.info(`Данные лабораторной работы ${labId} успешно получены`)
			return lab
		} catch (error) {
			logger.error(`Ошибка при получении данных лабораторной работы: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async getStudentsByLab(labId) {
		try {
			const result = await pool.query(
				`SELECT 
					s.user_id, 
					CONCAT_WS(' ', s.last_name, s.first_name, s.middle_name) AS full_name,
					ls.grade, 
					ls.submitted_at,
					g.name AS group_name,
					COALESCE(
						json_agg(lsf.file_name) FILTER (WHERE lsf.file_name IS NOT NULL),
						'[]'
					) AS report_files
				FROM lab_submissions ls
				JOIN students s ON ls.student_id = s.user_id
				LEFT JOIN groups g ON s.group_id = g.id
				LEFT JOIN lab_submission_files lsf ON lsf.lab_submission_id = ls.id
				WHERE ls.lab_id = $1
				GROUP BY s.user_id, full_name, ls.grade, ls.submitted_at, g.name`,
				[labId]
			)
			return result.rows.map(row => ({
				fio: row.full_name?.trim() || 'ФИО не указано',
				user_id: row.user_id,
				grade: row.grade !== null ? row.grade : 'Не оценено',
				submitted_at: row.submitted_at,
				group_name: row.group_name || 'Без группы',
				report_files: row.report_files || []
			}))
		} catch (error) {
			logger.error(`Ошибка при получении студентов для лабораторной работы: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError(`Ошибка получения данных студентов по ЛБ ${labId}`)
		}
	}

	async getStudentSubmission(labId, studentId) {
		try {
			const result = await pool.query(
				`SELECT 
									ls.id, 
									ls.submitted_at, 
									(SELECT array_agg(file_name) FROM lab_submission_files WHERE lab_submission_id = ls.id) as files
							 FROM lab_submissions ls
							 WHERE ls.lab_id = $1 AND ls.student_id = $2`,
				[labId, studentId]
			)
			logger.info(`Отчёт получен для лабораторной ${labId}, студент ${studentId}`)
			return result.rows[0]
		} catch (error) {
			logger.error(`Ошибка при получении отчёта студента: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async deleteLab(labId) {
		try {
			const __filename = fileURLToPath(import.meta.url)
			const __dirname = path.dirname(__filename)
			const projectRoot = path.resolve(__dirname, '../../')
			logger.info(`Удаление лабораторной работы: ${labId}`)
			await pool.query('BEGIN')
			const labFilesResult = await pool.query(
				`SELECT file_name, file_path FROM lab_files WHERE lab_id = $1`,
				[labId]
			)
			const labFilePaths = labFilesResult.rows
			const submissionFilesResult = await pool.query(
				`
					SELECT lsf.file_name, lsf.file_path
					FROM lab_submission_files lsf
					JOIN lab_submissions ls ON lsf.lab_submission_id = ls.id
					WHERE ls.lab_id = $1
					`,
				[labId]
			)
			const submissionFilePaths = submissionFilesResult.rows
			logger.info('Удаление лабораторной работы из таблицы labs')
			const deleteLabResult = await pool.query(
				`DELETE FROM labs WHERE id = $1 RETURNING id`,
				[labId]
			)
			if (deleteLabResult.rows.length === 0) {
				logger.error('Лабораторная работа не найдена')
				throw ApiError.NotFound('Лабораторная работа не найдена')
			}
			for (const file of labFilePaths) {
				const filePath = path.join(projectRoot, 'uploads/labs', file.file_name)
				if (fs.existsSync(filePath)) {
					await fsp.unlink(filePath)
					logger.info(`Файл лабораторной работы успешно удалён: ${filePath}`)
				} else {
					logger.warn(`Файл лабораторной работы не найден: ${filePath}`)
					throw ApiError.BadRequest('Ошибка удаления')
				}
			}
			for (const file of submissionFilePaths) {
				const filePath = path.join(projectRoot, 'uploads/submissions', file.file_name)
				if (fs.existsSync(filePath)) {
					await fsp.unlink(filePath)
					logger.info(`Файл ответа студента успешно удалён: ${filePath}`)
				} else {
					logger.warn(`Файл ответа студента не найден: ${filePath}`)
					throw ApiError.BadRequest('Ошибка удаления')
				}
			}
			await pool.query('COMMIT')
			logger.info(`Лабораторная работа ${labId} успешно удалена`)
		} catch (error) {
			await pool.query('ROLLBACK')
			logger.error(`Ошибка при удалении лабораторной работы: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError(`Не удалось удалить лабораторную работу ${labId}`)
		}
	}



	async updateLab(labId, updatedLabData, deleteAllFiles = false) {
		const __filename = fileURLToPath(import.meta.url)
		const __dirname = path.dirname(__filename)
		const projectRoot = path.resolve(__dirname, '../../')
		logger.info(`Обновление лабораторной работы: ${labId}`)
		try {
			await pool.query('BEGIN')
			const { title, description, files } = updatedLabData
			const labResult = await pool.query(
				`SELECT id FROM labs WHERE id = $1`,
				[labId]
			)
			if (labResult.rows.length === 0) {
				logger.error('Лабораторная работа не найдена')
				throw ApiError.NotFound('Лабораторная работа не найдена')
			}
			const fieldsToUpdate = []
			const values = [labId]
			let paramIndex = 2
			if (title) {
				fieldsToUpdate.push(`title = $${paramIndex}`)
				values.push(title)
				paramIndex++
			}
			if (description) {
				fieldsToUpdate.push(`description = $${paramIndex}`)
				values.push(description)
				paramIndex++
			}
			if (fieldsToUpdate.length > 0) {
				logger.info('Обновление labs:', fieldsToUpdate)
				await pool.query(
					`
					UPDATE labs
					SET ${fieldsToUpdate.join(', ')}
					WHERE id = $1
					`,
					values
				)
			}
			const currentFilesResult = await pool.query(
				`SELECT file_name, file_path FROM lab_files WHERE lab_id = $1`,
				[labId]
			)
			const currentFiles = currentFilesResult.rows
			const currentFileNames = currentFiles.map(f => f.file_name)
			const newFileNames = files ? files.map(f => f.file_name) : []
			let filesToDelete = []
			if (deleteAllFiles || newFileNames.length === 0) {
				filesToDelete = currentFiles
			} else {
				filesToDelete = currentFiles.filter(f => !newFileNames.includes(f.file_name))
			}
			const filesToAdd = files ? files.filter(f => !currentFileNames.includes(f.file_name)) : []
			if (filesToDelete.length > 0) {
				await pool.query(
					`
					DELETE FROM lab_files
					WHERE lab_id = $1 AND file_name = ANY($2)
					`,
					[labId, filesToDelete.map(f => f.file_name)]
				)
				for (const file of filesToDelete) {
					const filePath = path.join(projectRoot, 'uploads/labs', file.file_name)
					if (fs.existsSync(filePath)) {
						fs.unlinkSync(filePath)
						logger.info(`Удалён файл с сервера: ${filePath}`)
					} else {
						logger.warn(`Файл не найден на сервере: ${filePath}`)
					}
				}
			}
			if (filesToAdd.length > 0) {
				for (const file of filesToAdd) {
					const fileId = uuidv4()
					await pool.query(
						`
						INSERT INTO lab_files (id, lab_id, file_name, file_path)
						VALUES ($1, $2, $3, $4)
						`,
						[fileId, labId, file.file_name, file.file_path]
					)
					logger.info(`Добавлен файл в lab_files: ${file.file_name}, path: ${file.file_path}`)
				}
			}
			const updatedFilesResult = await pool.query(
				`SELECT file_name, file_path FROM lab_files WHERE lab_id = $1`,
				[labId]
			)
			const updatedFiles = updatedFilesResult.rows
			await pool.query('COMMIT')
			logger.info(`Лабораторная работа ${labId} успешно обновлена`)
			return {
				message: 'ЛБ успешно обновлена',
				files: updatedFiles
			}
		} catch (error) {
			await pool.query('ROLLBACK')
			logger.error(`Ошибка при обновлении лабораторной работы: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError('Не удалось обновить лабораторную работу')
		}
	}

	async downloadFile(filename) {
		try {
			logger.info(`Downloading file: ${filename}`)
			const __filename = fileURLToPath(import.meta.url)
			const __dirname = path.dirname(__filename)
			const filePath = path.join(__dirname, '../../uploads/labs', filename)
			if (!fs.existsSync(filePath)) {
				return { exists: false, filePath }
			}
			return { exists: true, filePath }
		} catch (error) {
			logger.error(`Error downloading file: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async getAllLabs() {
		try {
			logger.info('Получение всех лабораторных работ')
			const labsResult = await pool.query(
				`SELECT 
					 l.id, 
					 l.title, 
					 array_agg(g.name) AS group_names
				 FROM labs l
				 LEFT JOIN lab_groups lg ON l.id = lg.lab_id
				 LEFT JOIN groups g ON lg.group_id = g.id
				 GROUP BY l.id`
			)
			logger.info(`Успешно получено лабораторных работ: ${labsResult.rows.length}`)
			return labsResult.rows
		} catch (error) {
			logger.error(`Ошибка при получении лабораторных работ: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async searchLabs(query) {
		try {
			logger.info(`Поиск лабораторных работ по запросу: "${query}"`)
			const searchQuery = `%${query}%`
			const labsResult = await pool.query(
				`SELECT 
					 l.id, 
					 l.title, 
					 array_agg(g.name) AS group_names
				 FROM labs l
				 LEFT JOIN lab_groups lg ON l.id = lg.lab_id
				 LEFT JOIN groups g ON lg.group_id = g.id
				 WHERE l.title ILIKE $1
				 GROUP BY l.id`,
				[searchQuery]
			)
			logger.info(`Найдено лабораторных работ: ${labsResult.rows.length} по запросу: "${query}"`)
			return labsResult.rows
		} catch (error) {
			logger.error(`Ошибка при поиске лабораторных работ: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async updateStudentGrade(labId, studentId, grade) {
		try {
			logger.info(`Обновление оценки ЛБ ${labId}, студент ${studentId}`)
			const result = await pool.query(
				`UPDATE lab_submissions 
                 SET grade = $1 
                 WHERE lab_id = $2 AND student_id = $3 
                 RETURNING *`,
				[grade, labId, studentId]
			)
			logger.info(`Оценка обновлена ЛБ ${labId}, студент ${studentId}`)
			return result
		} catch (error) {
			logger.error(`Ошибка обновления оценки: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async getSubjectsByLecturer(lecturerId) {
		try {
			const result = await pool.query(
				`SELECT DISTINCT s.id, s.name
                 FROM subjects s
                 JOIN labs l ON s.id = l.subject_id
                 WHERE l.lecturer_id = $1`,
				[lecturerId]
			)
			logger.info(`[ОТЧЕТ] Получено ${result.rows.length} предметов для lecturer: ${lecturerId}`)
			return result.rows
		} catch (error) {
			logger.error(`[ОТЧЕТ] Ошибка получения предметов lecturer: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async getGroupsBySubject(lecturerId, subjectId) {
		try {
			const result = await pool.query(`
				SELECT DISTINCT g.id, g.name
				FROM groups g
				JOIN lab_groups lg ON g.id = lg.group_id
				JOIN labs l ON lg.lab_id = l.id
				WHERE l.lecturer_id = $1 AND l.subject_id = $2
			`, [lecturerId, subjectId])
			logger.info(`[ОТЧЕТ] Получено ${result.rows.length} групп для lecturer: ${lecturerId}`)
			return result.rows
		} catch (error) {
			logger.error(`[ОТЧЕТ] Ошибка получения групп lecturer: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async getStudentsByGroupAndSubject(groupId, subjectId, lecturerId) {
		try {
			const result = await pool.query(`
				SELECT 
					s.user_id, 
					s.first_name, 
					s.middle_name, 
					s.last_name,
					COUNT(DISTINCT ls.id) FILTER (WHERE ls.grade IS NOT NULL AND l.subject_id = $2) AS completed_labs,
					COUNT(DISTINCT l.id) FILTER (WHERE l.subject_id = $2) AS total_labs,
					json_agg(
						jsonb_build_object(
							'lab_id', ls.lab_id,
							'title', l.title,
							'grade', ls.grade,
							'subject', s2.name,
							'created', l.created
						)
						ORDER BY l.created DESC
					) FILTER (WHERE ls.lab_id IS NOT NULL AND l.subject_id = $2) AS labs
				FROM students s
				LEFT JOIN lab_submissions ls ON s.user_id = ls.student_id
				LEFT JOIN labs l ON l.id = ls.lab_id
				LEFT JOIN subjects s2 ON l.subject_id = s2.id
				JOIN lecturer_groups lg ON s.group_id = lg.group_id
				WHERE s.group_id = $1 AND lg.lecturer_id = $3
				GROUP BY s.user_id, s.first_name, s.middle_name, s.last_name
			`, [groupId, subjectId, lecturerId])

			return result.rows.map(row => {
				const grades = (row.labs || []).map(lab => lab.grade !== null ? lab.grade : 0)
				const unsumbittedLabs = row.total_labs - grades.length
				for (let i = 0; i < unsumbittedLabs; i++) {
					grades.push(0)
				}
				let avg_grade = null
				if (row.total_labs > 0) {
					const sum = grades.reduce((a, b) => a + b, 0)
					const avg = sum / row.total_labs
					avg_grade = Number.isInteger(avg) ? avg : parseFloat(avg.toFixed(2))
				}

				return {
					...row,
					avg_grade,
					labs: (row.labs || []).map(({ lab_id, title, grade, subject }) => ({
						lab_id,
						title,
						grade,
						subject
					}))
				}
			})
		} catch (error) {
			logger.error(`Ошибка получения студентов: ${error.message}`)
			throw ApiError.InternalError()
		}
	}


	async getGroupsAndSubjectsByLecturer(lecturerId) {
		try {
			logger.info(`Получение групп и предметов для преподавателя с ID: ${lecturerId}`)
			const groupsResult = await pool.query(`
				SELECT g.id, g.name
				FROM groups g
				JOIN lecturer_groups lg ON lg.group_id = g.id
				WHERE lg.lecturer_id = $1
				ORDER BY g.name ASC
			`, [lecturerId])
			const subjectsResult = await pool.query(`
				SELECT s.id, s.name
				FROM subjects s
				JOIN lecturer_subjects ls ON ls.subject_id = s.id
				WHERE ls.lecturer_id = $1
				ORDER BY s.name ASC
			`, [lecturerId])

			logger.info(`Группы и предметы успешно получены для преподавателя с ID: ${lecturerId}`)

			return {
				groups: groupsResult.rows,
				subjects: subjectsResult.rows
			}
		} catch (error) {
			logger.error(`Ошибка при получении групп и предметов для преподавателя: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	async uploadSubmission(labId, studentId, fileNames, filePaths) {
		try {
			await pool.query('BEGIN')
			const submissionResult = await pool.query(
				`SELECT id FROM lab_submissions WHERE lab_id = $1 AND student_id = $2`,
				[labId, studentId]
			)
			if (submissionResult.rows.length === 0) {
				throw ApiError.BadRequest('ЛБ не найдена')
			}
			const submissionId = submissionResult.rows[0].id
			for (let i = 0; i < fileNames.length; i++) {
				const fileId = uuidv4()
				await pool.query(
					`INSERT INTO lab_submission_files (id, lab_submission_id, file_name, file_path) 
									 VALUES ($1, $2, $3, $4)`,
					[fileId, submissionId, fileNames[i], filePaths[i]]
				)
			}
			await pool.query(
				`UPDATE lab_submissions 
							 SET submitted_at = CURRENT_TIMESTAMP 
							 WHERE id = $1`,
				[submissionId]
			)
			await pool.query('COMMIT')
			logger.info(`Отчет загружен для ЛБ ${labId}, студент ${studentId}`)
			return { files: fileNames }
		} catch (error) {
			await pool.query('ROLLBACK')
			logger.error(`Ошибка при загрузке отчета для ЛБ ${labId}, студент ${studentId}: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async downloadSubmissionFile(filename) {
		try {
			logger.info(`Скачивание файла отчёта: ${filename}`)
			const __filename = fileURLToPath(import.meta.url)
			const __dirname = path.dirname(__filename)
			const filePath = path.join(__dirname, '../../uploads/submissions', filename)
			if (!fs.existsSync(filePath)) {
				return { exists: false, filePath }
			}
			return { exists: true, filePath }
		} catch (error) {
			logger.error(`Ошибка скачивания файла отчёта: ${error.message}`)
			throw ApiError.InternalError()
		}
	}
}

export default new LabService()