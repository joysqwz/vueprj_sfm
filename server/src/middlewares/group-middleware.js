import service from '../service/grp-subj-service.js'
import { ApiError } from '../exceptions/api-error.js'
import logger from '../config/logger.js'
import { pool } from '../config/db.js'

export const groupMiddleware = async (req, res, next) => {
	let users = req.body.users
	if (!Array.isArray(users)) users = [users]
	if (users.length === 0) return next(ApiError.BadRequest('Список пользователей пуст'))

	const validateUser = user => user && user.role === 'student' && user.group
	const groupNames = [...new Set(users
		.filter(validateUser)
		.map(user => user.group)
		.filter(name => name !== undefined && name !== null)
	)]
	if (groupNames.length === 0) return next()

	try {
		logger.info(`Проверка существующих групп: ${groupNames.join(', ')}`)
		const existingGroups = await pool.query(
			'SELECT id, name FROM groups WHERE name = ANY($1)',
			[groupNames]
		)
		const groupMap = new Map()
		existingGroups.rows.forEach(group => {
			groupMap.set(group.name, group.id)
		})
		const newGroupNames = groupNames.filter(name => !groupMap.has(name))
		if (newGroupNames.length > 0) {
			logger.info(`Найдено новых групп для добавления: ${newGroupNames.join(', ')}`)
			for (let name of newGroupNames) {
				await service.addGroup(name)
				logger.info(`Группа добавлена: ${name}`)
			}
			const addedGroups = await pool.query(
				'SELECT id, name FROM groups WHERE name = ANY($1)',
				[newGroupNames]
			)
			addedGroups.rows.forEach(group => {
				groupMap.set(group.name, group.id)
			})
		}
		users = users.map(user => {
			if (user.role === 'student' && user.group) {
				user.group = groupMap.get(user.group) || user.group
			}
			return user
		})
		req.body.users = users
		next()

	} catch (error) {
		logger.error(`Ошибка при добавлении групп или обработке пользователей: ${error.message}`)
		next(error instanceof ApiError ? error : ApiError.InternalError(error.message))
	}
}
