import pkg from 'pg'
import dotenv from 'dotenv'
import { ApiError } from '../exceptions/api-error.js'
import cron from 'node-cron'
import logger from './logger.js'
import { exec } from 'child_process'
import path from 'path'
import fs from 'fs'

const { Pool } = pkg
dotenv.config()

export const pool = new Pool({
	user: process.env.DB_USER,
	host: process.env.DB_HOST,
	database: process.env.DB_NAME,
	password: process.env.DB_PASSWORD,
	port: process.env.DB_PORT,
})

pool.on('error', (err) => {
	console.error('Неожиданная ошибка пула базы данных:', err)
})

export const checkConnection = async () => {
	try {
		const client = await pool.connect()
		client.release()
		return true
	} catch (err) {
		console.error('Ошибка подключения к базе данных:', err)
		throw ApiError.InternalError('Ошибка подключения к базе данных')
	}
}

export const query = async (text, params) => {
	try {
		const result = await pool.query(text, params)
		return result
	} catch (err) {
		console.error('Ошибка выполнения запроса:', err)
		throw err
	}
}

const BACKUP_DIR = path.resolve('./db_backups')

if (!fs.existsSync(BACKUP_DIR)) {
	fs.mkdirSync(BACKUP_DIR, { recursive: true })
}

cron.schedule('0 0 * * *', async () => {
	try {
		const result = await pool.query(
			'DELETE FROM temp_tokens WHERE expires_at < NOW()'
		)
		logger.info(`[CRON] Очистка temp_tokens. Удалено ${result.rowCount}`)
	} catch (error) {
		logger.error('[CRON] Ошибка при очистке temp_tokens:', error.message)
	}

	try {
		await createBackup()
	} catch (error) {
		logger.error('[CRON] Ошибка при создании дампа:', error.message)
	}
})
