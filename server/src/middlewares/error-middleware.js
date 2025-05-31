import { ApiError } from '../exceptions/api-error.js'

export function errorMiddleware(err, req, res, next) {
	console.error('Ошибка:', {
		message: err.message,
		stack: err.stack,
		path: req.path,
		method: req.method,
		body: req.body,
		query: req.query,
		params: req.params
	})

	if (err.code === 'LIMIT_FILE_TYPE') {
		return res.status(400).json({ message: err.message })
	}

	if (err instanceof ApiError) {
		return res.status(err.status).json(err.toJSON())
	}

	return res.status(500).json({ message: 'Непредвиденная ошибка' })
}
