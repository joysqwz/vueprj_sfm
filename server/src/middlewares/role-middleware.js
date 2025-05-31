import { ApiError } from '../exceptions/api-error.js'
import tokenService from '../service/token-service.js'

export function roleMiddleware(roles) {
	return function (req, res, next) {
		try {
			const accessToken = req.cookies.accessToken
			if (!accessToken) {
				return next(ApiError.UnauthorizedError())
			}
			const userData = tokenService.validateAccessToken(accessToken)
			if (!userData) {
				return next(ApiError.UnauthorizedError())
			}
			let normalizedRoles = []
			if (Array.isArray(roles)) {
				if (roles.length === 1 && typeof roles[0] === 'string' && roles[0].includes(',')) {
					normalizedRoles = roles[0].split(',').map(role => role.trim())
				} else {
					normalizedRoles = roles
				}
			} else if (typeof roles === 'string') {
				normalizedRoles = roles.split(',').map(role => role.trim())
			}
			const hasRole = normalizedRoles.includes(userData.role)
			if (!hasRole) {
				return next(ApiError.ForbiddenError())
			}
			req.user = userData
			next()
		} catch (error) {
			if (error instanceof ApiError) {
				next(error)
			} else {
				next(ApiError.InternalError())
			}
		}
	}
}