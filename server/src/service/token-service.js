import jwt from "jsonwebtoken"
import { pool } from '../config/db.js'
import { ApiError } from '../exceptions/api-error.js'
import logger from '../config/logger.js'
import { v4 as uuidv4 } from 'uuid'
import * as tokenConfig from '../config/jwt-config.js'

class TokenService {
	generateTokens(payload) {
		try {
			const jti = uuidv4()
			payload.jti = jti
			logger.info(`Генерация токенов для пользователя: ${payload.sub}`)
			const accessToken = jwt.sign({ sub: payload.sub, role: payload.role }, process.env.JWT_ACCESS_SECRET, { expiresIn: `${tokenConfig.JWT_ACCESS}m` })
			const refreshToken = jwt.sign({ sub: payload.sub, jti: payload.jti, unique_id: payload.unique_id }, process.env.JWT_REFRESH_SECRET, { expiresIn: `${tokenConfig.JWT_REFRESH}d` })
			logger.info(`Токены успешно сгенерированы для пользователя: ${payload.sub}`)
			return { accessToken, refreshToken, jti }
		} catch (error) {
			logger.error(`Ошибка при генерации токенов: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	generateTempToken(payload) {
		try {
			logger.info(`Генерация temp-токена для пользователя: ${payload}`)
			const tempToken = jwt.sign({ sub: payload }, process.env.JWT_TEMP_SECRET, {
				expiresIn: '10m'
			})
			logger.info(`Temp-токен успешно сгенерирован для пользователя: ${payload}`)
			return tempToken
		} catch (error) {
			logger.error(`Ошибка при генерации temp-токена: ${error.message}`)
			throw ApiError.InternalError()
		}
	}

	validateAccessToken(token) {
		try {
			logger.info('Попытка валидации access-токена')
			const userData = jwt.verify(token, process.env.JWT_ACCESS_SECRET)
			logger.info(`Access-токен успешно валидирован для пользователя: ${userData.sub}`)
			return userData
		} catch (error) {
			logger.warn('Ошибка валидации access-токена')
			throw ApiError.UnauthorizedError()
		}
	}

	validateRefreshToken(token) {
		try {
			logger.info('Попытка валидации refresh-токена')
			const userData = jwt.verify(token, process.env.JWT_REFRESH_SECRET)
			logger.info(`Refresh-токен успешно валидирован для пользователя: ${userData.sub}`)
			return userData
		} catch (error) {
			logger.warn('Ошибка валидации refresh-токена')
			throw ApiError.UnauthorizedError()
		}
	}

	validateTempToken(token) {
		try {
			logger.info('Попытка валидации temp-токена')
			const userData = jwt.verify(token, process.env.JWT_TEMP_SECRET)
			logger.info(`Temp-токен успешно валидирован для пользователя: ${userData.sub}`)
			return userData
		} catch (error) {
			logger.warn('Ошибка валидации temp-токена')
			throw ApiError.UnauthorizedError()
		}
	}

	async saveToken(uid, userId, refreshToken, ipAddress, userAgent, jti) {
		try {
			const expiresAt = new Date(Date.now() + tokenConfig.JWT_REFRESH * 24 * 60 * 60 * 1000)
			const result = await pool.query(
				`SELECT * FROM tokens WHERE user_id = $1 AND unique_id = $2`,
				[userId, uid]
			)
			if (result.rows.length > 0) {
				const tokenData = await pool.query(
					`UPDATE tokens 
					 SET refresh_token = $1, user_agent = $2, ip_address = $3, expires_at = $4, created_at = CURRENT_TIMESTAMP, is_revoked = FALSE
					 WHERE user_id = $5 AND unique_id = $6 
					 RETURNING *`,
					[refreshToken, userAgent, ipAddress, expiresAt, userId, uid]
				)
				logger.info(`Refresh-токен обновлён для userId=${userId}, uid=${uid}`)
				return tokenData.rows[0]
			} else {
				const token = await pool.query(
					`INSERT INTO tokens (id, user_id, refresh_token, ip_address, user_agent, unique_id, expires_at)
					 VALUES ($1, $2, $3, $4, $5, $6, $7) 
					 RETURNING *`,
					[jti, userId, refreshToken, ipAddress, userAgent, uid, expiresAt]
				)
				logger.info(`Refresh-токен создан для userId=${userId}, uid=${uid}`)
				return token.rows[0]
			}
		} catch (error) {
			logger.error(`Ошибка при сохранении refresh-токен: ${error.message}, userId=${userId}, uid=${uid}`)
			throw ApiError.InternalError(error.message)
		}
	}

	async removeToken(refreshToken) {
		try {
			logger.info('Попытка отзыва refresh-токена')
			const tokenData = await pool.query(
				`UPDATE tokens 
                 SET is_revoked = TRUE, expires_at = CURRENT_TIMESTAMP
                 WHERE refresh_token = $1 
                 RETURNING *`,
				[refreshToken]
			)
			logger.info(`Refresh-токен успешно отозван для пользователя: ${tokenData.rows[0].user_id}`)
			return
		} catch (error) {
			logger.error(`Ошибка при отзыве refresh-токена: ${error.message}`)
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async findToken(refreshToken) {
		try {
			logger.info('Поиск refresh-токена в базе данных')
			const tokenData = await pool.query(
				`SELECT * FROM tokens 
                 WHERE refresh_token = $1 AND is_revoked = FALSE AND expires_at > CURRENT_TIMESTAMP`,
				[refreshToken]
			)
			if (tokenData.rows.length) {
				logger.info('Refresh-токен найден в базе данных')
				return tokenData.rows[0]
			} else {
				logger.warn('Refresh-токен не найден или истек/отозван')
				return null
			}
		} catch (error) {
			logger.error(`Ошибка при поиске refresh-токена: ${error.message}`)
			throw ApiError.InternalError()
		}
	}
}

export default new TokenService()
