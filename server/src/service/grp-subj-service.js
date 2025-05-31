import { pool } from '../config/db.js'
import { ApiError } from '../exceptions/api-error.js'
import { v4 as uuidv4 } from 'uuid'

class GrpSubjService {
	async getAllGroups() {
		try {
			const result = await pool.query('SELECT * FROM groups ORDER BY name')
			return result.rows
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}
	async addGroup(name) {
		try {
			const check = await pool.query('SELECT * FROM groups WHERE name = $1', [name])
			if (check.rows.length > 0) {
				throw ApiError.BadRequest(`Группа "${name}" уже существует`)
			}

			const id = uuidv4()
			const result = await pool.query(
				'INSERT INTO groups (id, name) VALUES ($1, $2) RETURNING *',
				[id, name]
			)
			return result.rows[0]
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}
	async updateGroup(id, name) {
		try {
			const check = await pool.query('SELECT * FROM groups WHERE name = $1 AND id != $2', [name, id])
			if (check.rows.length > 0) {
				throw ApiError.BadRequest(`Группа с именем "${name}" уже существует`)
			}
			const result = await pool.query(
				'UPDATE groups SET name = $1 WHERE id = $2 RETURNING *',
				[name, id]
			)
			if (result.rowCount === 0) {
				throw ApiError.NotFound(`Группа с id "${id}" не найдена`)
			}
			return result.rows[0]
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}
	async deleteGroup(id) {
		try {
			const result = await pool.query('DELETE FROM groups WHERE id = $1 RETURNING *', [id])
			if (result.rowCount === 0) {
				throw ApiError.NotFound(`Группа с id "${id}" не найдена`)
			}
			return { success: true }
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async getAllSubjects() {
		try {
			const result = await pool.query('SELECT * FROM subjects ORDER BY name')
			return result.rows
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}
	async addSubject(name) {
		try {
			const check = await pool.query('SELECT * FROM subjects WHERE name = $1', [name])
			if (check.rows.length > 0) {
				throw ApiError.BadRequest(`Предмет "${name}" уже существует`)
			}
			const id = uuidv4()
			const result = await pool.query(
				'INSERT INTO subjects (id, name) VALUES ($1, $2) RETURNING *',
				[id, name]
			)
			return result.rows[0]
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}
	async updateSubject(id, name) {
		try {
			const check = await pool.query('SELECT * FROM subjects WHERE name = $1 AND id != $2', [name, id])
			if (check.rows.length > 0) {
				throw ApiError.BadRequest(`Предмет с именем "${name}" уже существует`)
			}
			const result = await pool.query(
				'UPDATE subjects SET name = $1 WHERE id = $2 RETURNING *',
				[name, id]
			)
			if (result.rowCount === 0) {
				throw ApiError.NotFound(`Предмет с id "${id}" не найден`)
			}
			return result.rows[0]
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}
	async deleteSubject(id) {
		try {
			const result = await pool.query('DELETE FROM subjects WHERE id = $1 RETURNING *', [id])
			if (result.rowCount === 0) {
				throw ApiError.NotFound(`Предмет с id "${id}" не найден`)
			}
			return { success: true }
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

	async getGroupsSubjects() {
		try {
			const groupsResult = await pool.query('SELECT * FROM groups ORDER BY name')
			const subjectsResult = await pool.query('SELECT * FROM subjects ORDER BY name')

			return {
				groups: groupsResult.rows,
				subjects: subjectsResult.rows
			}
		} catch (error) {
			throw error instanceof ApiError ? error : ApiError.InternalError()
		}
	}

}

export default new GrpSubjService()
