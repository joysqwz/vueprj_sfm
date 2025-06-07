import { describe, it, expect, vi, beforeEach } from 'vitest'
import userService from '../service/user-service.js'
import { ApiError } from '../exceptions/api-error.js'
import logger from '../config/logger.js'
import { pool } from '../config/db.js'
import bcrypt from 'bcryptjs'
import { v4 as uuidv4 } from 'uuid'
import mailService from '../service/mail-service.js'
import tokenService from '../service/token-service.js'

vi.mock('../config/logger.js', () => ({
	default: {
		info: vi.fn(),
		error: vi.fn(),
	},
}))

vi.mock('../service/token-service.js', () => ({
	default: {
		removeToken: vi.fn(),
	}
}))

vi.mock('../config/db.js', () => ({
	pool: {
		query: vi.fn(),
	},
}))

vi.mock('bcryptjs', () => ({
	__esModule: true,
	default: {
		hash: vi.fn(),
	},
}))

vi.mock('uuid', () => ({
	v4: vi.fn(),
}))

vi.mock('../service/mail-service.js', () => ({
	default: {
		sendInfoUser: vi.fn(),
	},
}))

describe('registrationAdmin', () => {
	beforeEach(() => {
		vi.clearAllMocks()
	})

	const users = [
		{
			first_name: 'Ivan',
			middle_name: 'Ivanovich',
			last_name: 'Ivanov',
			group: '101',
			role: 'student',
			email: 'ivan@example.com',
		},
		{
			first_name: 'Petr',
			middle_name: 'Petrovich',
			last_name: 'Petrov',
			role: 'lecturer',
			email: 'petr@example.com',
		},
		{
			role: 'admin',
			email: 'admin@example.com',
		},
	]

	it('Регистрация студента/преподавателя/администратора', async () => {
		// Проверка наличия пользователей в БД (SELECT) для каждого пользователя — возвращаем пустой результат (email не занят)
		pool.query.mockResolvedValueOnce({ rows: [] }) // для ivan
		pool.query.mockResolvedValueOnce({ rows: [] }) // для petr
		pool.query.mockResolvedValueOnce({ rows: [] }) // для admin

		// Мокаем хеширование пароля
		bcrypt.hash.mockResolvedValue('hashed-password')

		// Мокаем генерацию UUID для каждого пользователя
		uuidv4.mockReturnValueOnce('uuid-ivan')
			.mockReturnValueOnce('uuid-petr')
			.mockReturnValueOnce('uuid-admin')

		// Мокаем все INSERT запросы — они возвращают пустой результат (успешно)
		pool.query.mockResolvedValue({})

		// Запускаем тестируемую функцию
		await userService.registrationAdmin(users)

		// Проверяем, что проверка email выполнялась для каждого пользователя
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', ['ivan@example.com'])
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', ['petr@example.com'])
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', ['admin@example.com'])

		// Проверяем, что хеширование пароля и генерация UUID были вызваны 3 раза (по числу пользователей)
		expect(bcrypt.hash).toHaveBeenCalledTimes(3)
		expect(uuidv4).toHaveBeenCalledTimes(3)

		// Проверяем, что для каждого пользователя вставка в таблицу users выполнена с корректными данными
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO users (id, email, password, role) 
                 VALUES ($1, $2, $3, $4)`,
			['uuid-ivan', 'ivan@example.com', 'hashed-password', 'student']
		)
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO users (id, email, password, role) 
                 VALUES ($1, $2, $3, $4)`,
			['uuid-petr', 'petr@example.com', 'hashed-password', 'lecturer']
		)
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO users (id, email, password, role) 
                 VALUES ($1, $2, $3, $4)`,
			['uuid-admin', 'admin@example.com', 'hashed-password', 'admin']
		)

		// Проверяем вставку в таблицы в зависимости от роли
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO students (user_id, first_name, middle_name, last_name, group_id) 
                     VALUES ($1, $2, $3, $4, $5)`,
			['uuid-ivan', 'Ivan', 'Ivanovich', 'Ivanov', '101']
		)
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO lecturers (user_id, first_name, middle_name, last_name) 
                     VALUES ($1, $2, $3, $4)`,
			['uuid-petr', 'Petr', 'Petrovich', 'Petrov']
		)

		// Для admin дополнительной таблицы нет, проверяем, что вставка в students или lecturers не происходила для admin
		expect(pool.query).not.toHaveBeenCalledWith(
			expect.stringContaining('students'),
			expect.arrayContaining(['uuid-admin'])
		)
		expect(pool.query).not.toHaveBeenCalledWith(
			expect.stringContaining('lecturers'),
			expect.arrayContaining(['uuid-admin'])
		)

		// Проверяем вызовы отправки почты каждому пользователю
		expect(mailService.sendInfoUser).toHaveBeenCalledWith('ivan@example.com', 'ivan@example.com', expect.any(String))
		expect(mailService.sendInfoUser).toHaveBeenCalledWith('petr@example.com', 'petr@example.com', expect.any(String))
		expect(mailService.sendInfoUser).toHaveBeenCalledWith('admin@example.com', 'admin@example.com', expect.any(String))

		// Проверяем лог успешного добавления пользователей
		expect(logger.info).toHaveBeenCalledWith(`Успешно добавлено ${users.length} пользователей`)
	})

	it('Ошибка если email уже существует', async () => {
		// Для первого пользователя возвращаем, что такой email уже есть
		pool.query.mockResolvedValueOnce({ rows: [{ id: '1' }] })

		await expect(userService.registrationAdmin([users[0]])).rejects.toThrow(ApiError)

		// Проверяем, что логируется ошибка
		expect(logger.error).toHaveBeenCalledWith(expect.stringContaining('Ошибка при регистрации пользователей'))
		// Проверяем, что почта не отправилась, т.к. регистрация не прошла
		expect(mailService.sendInfoUser).not.toHaveBeenCalled()
	})
})


describe('logout', () => {
	const refreshToken = 'refresh-token'
	beforeEach(() => {
		vi.clearAllMocks()
	})
	it('должен вызывать removeToken и логировать успешный выход', async () => {
		tokenService.removeToken.mockResolvedValue()
		await userService.logout(refreshToken)
		expect(logger.info).toHaveBeenCalledWith('Попытка выхода')
		expect(tokenService.removeToken).toHaveBeenCalledWith(refreshToken)
		expect(logger.info).toHaveBeenCalledWith('Успешный выход')
	})
	it('должен логировать ошибку и выбрасывать ApiError при ошибке', async () => {
		const error = new Error('some error')
		tokenService.removeToken.mockRejectedValueOnce(error)
		await expect(userService.logout(refreshToken)).rejects.toThrowError(ApiError)
		expect(logger.error).toHaveBeenCalledWith(`Ошибка при выходе: ${error.message}`)
	})
})
