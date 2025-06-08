import userService from '../service/user-service.js'
import { validationResult } from 'express-validator'
import { ApiError } from '../exceptions/api-error.js'
import * as tokenConfig from '../config/jwt-config.js'
import tokenService from '../service/token-service.js'


class UserController {
	// async registration(req, res, next) {
	// 	try {
	// 		const errors = validationResult(req)
	// 		if (!errors.isEmpty()) {
	// 			return next(ApiError.ValidationError(errors.array()))
	// 		}
	// 		const { email, password } = req.body
	// 		await userService.registration(
	// 			email, password
	// 		)
	// 		return res.json({ message: 'success' })
	// 	} catch (error) {
	// 		next(error)
	// 	}
	// }

	async checkAuth(req, res, next) {
		try {
			const accessToken = req.cookies.accessToken
			if (!accessToken) {
				return res.status(401).json()
			}
			const userData = tokenService.validateAccessToken(accessToken)
			if (!userData) {
				return res.status(401).json()
			}
			return res.json({ user: { sub: userData.sub, role: userData.role } })
		} catch (error) {
			return res.status(401).json()
		}
	}

	async registrationAdmin(req, res, next) {
		try {
			const { users } = req.body
			if (!Array.isArray(users) || users.length === 0) {
				return next(ApiError.BadRequest('Ожидается непустой массив пользователей'))
			}
			await userService.registrationAdmin(users)
			const message = users.length === 1 ? 'Пользователь успешно добавлен' : `Успешно добавлено ${users.length} пользователей`
			return res.json({ message })
		} catch (error) {
			next(error)
		}
	}

	async login(req, res, next) {
		try {
			const errors = validationResult(req)
			if (!errors.isEmpty()) {
				return next(ApiError.BadRequest(errors.array()))
			}
			const { email, password } = req.body
			const uid = req.cookies.unique_id
			const userData = await userService.login(email, password, req.ip, req.get('User-Agent'), uid
			)
			if (userData && Object.keys(userData).length > 1) {
				res.cookie('accessToken', userData.accessToken, {
					maxAge: tokenConfig.JWT_ACCESS_LIFE,
					httpOnly: true,
					secure: true,
					sameSite: 'strict'
				})
				res.cookie('refreshToken', userData.refreshToken, {
					maxAge: tokenConfig.JWT_REFRESH_LIFE,
					httpOnly: true,
					secure: true,
					sameSite: 'strict'
				})
				return res.json({ sub: userData.user.sub, role: userData.user.role })
			} else {
				const tempToken = await userService.prepareNewDevice(userData.user_sub, email)
				res.cookie('tempToken', tempToken, {
					maxAge: 10 * 60 * 1000,
					httpOnly: true,
					secure: true,
					sameSite: 'strict'
				})
				return res.json({
					message: 'Требуется подтверждение нового устройства.',
				})
			}
		} catch (error) {
			next(error)
		}
	}

	async confirmNewDeviceCode(req, res, next) {
		try {
			const { code } = req.body
			const tempToken = req.cookies.tempToken
			const uniqueId = req.cookies.unique_id
			const userIp = req.ip
			const userAgent = req.get('User-Agent')
			if (!tempToken) {
				throw ApiError.UnauthorizedError('Токен отсутствует')
			}
			const userData = await userService.confirmNewDevice(code, tempToken, uniqueId, userIp, userAgent)
			res.cookie('accessToken', userData.accessToken, {
				maxAge: tokenConfig.JWT_ACCESS_LIFE,
				httpOnly: true,
				secure: true,
				sameSite: 'strict'
			})
			res.cookie('refreshToken', userData.refreshToken, {
				maxAge: tokenConfig.JWT_REFRESH_LIFE,
				httpOnly: true,
				secure: true,
				sameSite: 'strict'
			})
			res.clearCookie('tempToken')
			return res.json({ sub: userData.sub, role: userData.role })
		} catch (error) {
			next(error)
		}
	}

	async changePassword(req, res, next) {
		try {
			const errors = validationResult(req)
			if (!errors.isEmpty()) {
				return next(ApiError.BadRequest(errors.array()))
			}
			const userId = req.user.sub
			const { currentPassword, newPassword } = req.body
			await userService.changePassword(userId, currentPassword, newPassword)
			return res.json({ message: 'Пароль успешно изменен' })
		} catch (error) {
			next(error)
		}
	}

	async changeEmail(req, res, next) {
		try {
			const userId = req.user.sub
			const { currentEmail, newEmail } = req.body
			await userService.changeEmail(userId, currentEmail, newEmail)
			return res.json({ message: 'Email успешно изменен' })
		} catch (error) {
			next(error)
		}
	}

	async refresh(req, res, next) {
		try {
			const { refreshToken } = req.cookies
			if (!refreshToken) {
				return next(ApiError.UnauthorizedError())
			}
			const userData = await userService.refresh(refreshToken, req.ip, req.get('User-Agent'))
			if (userData && Object.keys(userData).length > 0) {
				res.cookie('accessToken', userData.accessToken, {
					maxAge: tokenConfig.JWT_ACCESS_LIFE,
					httpOnly: true,
					secure: true,
					sameSite: 'strict'
				})
				res.cookie('refreshToken', userData.refreshToken, {
					maxAge: tokenConfig.JWT_REFRESH_LIFE,
					httpOnly: true,
					secure: true,
					sameSite: 'strict'
				})
				return res.json({ sub: userData.user.sub, role: userData.user.role })
			}
			else {
				res.clearCookie('refreshToken', {
					httpOnly: true,
					secure: true,
					sameSite: 'strict',
				})
				res.clearCookie('accessToken', {
					httpOnly: true,
					secure: true,
					sameSite: 'strict',
				})
				throw ApiError.UnauthorizedError('Refresh token испарился')
			}
		} catch (error) {
			next(error)
		}
	}

	async logout(req, res, next) {
		try {
			const refreshToken = req.cookies.refreshToken
			await userService.logout(refreshToken)
			res.clearCookie('refreshToken', {
				httpOnly: true,
				secure: true,
				sameSite: 'strict',
			})
			res.clearCookie('accessToken', {
				httpOnly: true,
				secure: true,
				sameSite: 'strict',
			})
			return res.json({ message: 'Вы успешно вышли' })
		} catch (error) {
			next(error)
		}
	}

	async getProfile(req, res, next) {
		try {
			const { sub, role } = req.user
			const profileData = await userService.getProfile(sub, role)
			return res.json(profileData)
		} catch (error) {
			next(error)
		}
	}

	async getAccessAdmin(req, res, next) {
		try {
			return res.json({ message: 'Доступ получен' })
		} catch (error) {
			next(error)
		}
	}

	async getUsers(req, res, next) {
		try {
			const users = await userService.getUsers()
			return res.json({ users })
		} catch (error) {
			next(error)
		}
	}

	async searchUsers(req, res, next) {
		try {
			const { query } = req.query
			if (!query) {
				return next(ApiError.BadRequest('Запрос поиска пуст'))
			}
			const users = await userService.searchUsers(query)
			return res.json({ users })
		} catch (error) {
			next(error)
		}
	}

	async updateUser(req, res, next) {
		try {
			const { id } = req.params
			const myId = req.user.sub
			const userData = req.body
			await userService.updateUser(id, userData, myId)
			return res.json({ message: 'Пользователь обновлён' })
		} catch (error) {
			next(error)
		}
	}

	async deleteUser(req, res, next) {
		try {
			const { id } = req.params
			const myId = req.user.sub
			if (myId == id) { throw ApiError.BadRequest('Вы не можете удалить самого себя')}
			await userService.deleteUser(id)
			return res.json({ message: 'Пользователь удалён' })
		} catch (error) {
			next(error)
		}
	}

	async updateSubjects(req, res, next) {
		try {
			const userId = req.user.sub
			const { subjects } = req.body
			await userService.updateSubjects(userId, subjects)
			return res.json({ message: 'Предметы успешно обновлены' })
		} catch (error) {
			next(error)
		}
	}

	async updateGroups(req, res, next) {
		try {
			const userId = req.user.sub
			const { groups } = req.body
			await userService.updateGroups(userId, groups)
			return res.json({ message: 'Группы успешно обновлены' })
		} catch (error) {
			next(error)
		}
	}

	async quitSessions(req, res, next) {
		try {
			const { id } = req.params
			const myId = req.user.sub
			if (myId == id) {
				throw ApiError.BadRequest('Вы не можете обнулить сессии у самого себя')
			}
			await userService.quitSessions(id)
			return res.json({ message: 'Все сессии пользователя завершены' })
		} catch (error) {
			next(error)
		}
	}
}

export default new UserController()
