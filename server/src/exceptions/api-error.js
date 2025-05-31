export class ApiError extends Error {
	status
	message

	constructor(status, message) {
		super(message)
		this.status = status
		this.message = message
	}

	static BadRequest(message = 'Некорректный запрос') {
		return new ApiError(400, message)
	}
	static UnauthorizedError(message = 'Пользователь не авторизован') {
		return new ApiError(401, message)
	}

	static ForbiddenError(message = 'Доступ запрещён') {
		return new ApiError(403, message)
	}

	static NotFound(message = 'Ресурс не найден') {
		return new ApiError(404, message)
	}

	static InternalError(message = 'Внутренняя ошибка сервера') {
		return new ApiError(500, message)
	}

	toJSON() {
		return {
			message: this.message,
		}
	}
}
