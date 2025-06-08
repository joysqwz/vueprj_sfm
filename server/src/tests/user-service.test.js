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
		generateTokens: vi.fn(),
		saveToken: vi.fn(),
		findToken: vi.fn(),
		generateTempToken: vi.fn(),
		validateTempToken: vi.fn(),
		validateAccessToken: vi.fn(),
		validateRefreshToken: vi.fn(),
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
		compare: vi.fn()
	}
}))


vi.mock('uuid', () => ({
	v4: vi.fn(),
}))

vi.mock('../service/mail-service.js', () => ({
	default: {
		sendInfoUser: vi.fn(),
		sendNewDeviceCode: vi.fn(),
		sendChangePassword: vi.fn(),
		sendChangeEmail: vi.fn()
	},
}))

describe('registrationAdmin', () => {
	beforeEach(() => {
		vi.restoreAllMocks()
	})

	const users = [
		{
			first_name: 'Иван',
			middle_name: 'Иванович',
			last_name: 'Иванов',
			group: 'ПО1-21',
			role: 'student',
			email: 'ivan@examplexample.com',
		},
		{
			first_name: 'Петр',
			middle_name: 'Петрович',
			last_name: 'Петров',
			role: 'lecturer',
			email: 'petr@examplexample.com',
		},
		{
			role: 'admin',
			email: 'admin@examplexample.com',
		},
	]

	it('Регистрация студента/преподавателя/администратора', async () => {
		// Проверка наличия пользователей в БД (SELECT) для каждого пользователя — возвращаем пустой результат (email не занят)
		pool.query.mockResolvedValueOnce({ rows: [] }) // для Иван
		pool.query.mockResolvedValueOnce({ rows: [] }) // для Петр
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
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', ['ivan@examplexample.com'])
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', ['petr@examplexample.com'])
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', ['admin@examplexample.com'])

		// Проверяем, что хеширование пароля и генерация UUID были вызваны 3 раза (по числу пользователей)
		expect(bcrypt.hash).toHaveBeenCalledTimes(3)
		expect(uuidv4).toHaveBeenCalledTimes(3)

		// Проверяем, что для каждого пользователя вставка в таблицу users выполнена с корректными данными
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO users (id, email, password, role) 
                 VALUES ($1, $2, $3, $4)`,
			['uuid-ivan', 'ivan@examplexample.com', 'hashed-password', 'student']
		)
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO users (id, email, password, role) 
                 VALUES ($1, $2, $3, $4)`,
			['uuid-petr', 'petr@examplexample.com', 'hashed-password', 'lecturer']
		)
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO users (id, email, password, role) 
                 VALUES ($1, $2, $3, $4)`,
			['uuid-admin', 'admin@examplexample.com', 'hashed-password', 'admin']
		)

		// Проверяем вставку в таблицы в зависимости от роли
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO students (user_id, first_name, middle_name, last_name, group_id) 
                     VALUES ($1, $2, $3, $4, $5)`,
			['uuid-ivan', 'Иван', 'Иванович', 'Иванов', 'ПО1-21']
		)
		expect(pool.query).toHaveBeenCalledWith(
			`INSERT INTO lecturers (user_id, first_name, middle_name, last_name) 
                     VALUES ($1, $2, $3, $4)`,
			['uuid-petr', 'Петр', 'Петрович', 'Петров']
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
		expect(mailService.sendInfoUser).toHaveBeenCalledWith('ivan@examplexample.com', 'ivan@examplexample.com', expect.any(String))
		expect(mailService.sendInfoUser).toHaveBeenCalledWith('petr@examplexample.com', 'petr@examplexample.com', expect.any(String))
		expect(mailService.sendInfoUser).toHaveBeenCalledWith('admin@examplexample.com', 'admin@examplexample.com', expect.any(String))

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

describe('login', () => {
	beforeEach(() => {
		vi.restoreAllMocks()
	})

	const mockUser = {
		id: 'user-123',
		email: 'test@examplexample.com',
		password: 'hashed-password',
		role: 'student',
	}
	const uid = 'device-abc'

	it('Успешный вход при корректных данных', async () => {
		pool.query
			.mockResolvedValueOnce({ rows: [mockUser] }) // поиск пользователя
			.mockResolvedValueOnce({ rows: [{ user_id: mockUser.id, unique_id: uid }] }) // проверка токенов
		bcrypt.compare.mockResolvedValue(true)

		const tokens = { accessToken: 'access', refreshToken: 'refresh', jti: 'jti-id' }
		const userDto = { sub: mockUser.id, email: mockUser.email, role: mockUser.role, unique_id: uid }
		tokenService.generateTokens = vi.fn().mockReturnValue(tokens)
		tokenService.saveToken = vi.fn()

		const result = await userService.login(mockUser.email, 'password', '127.0.0.1', 'UA', uid)

		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', [mockUser.email])
		expect(bcrypt.compare).toHaveBeenCalledWith('password', mockUser.password)
		expect(tokenService.generateTokens).toHaveBeenCalledWith(expect.objectContaining({ sub: mockUser.id }))
		expect(tokenService.saveToken).toHaveBeenCalledWith(uid, mockUser.id, tokens.refreshToken, '127.0.0.1', 'UA', 'jti-id')
		expect(result).toEqual(expect.objectContaining({ accessToken: 'access', refreshToken: 'refresh', user: expect.any(Object) }))
		expect(logger.info).toHaveBeenCalledWith(`Успешный вход пользователя: ${mockUser.email}`)
	})

	it('Вход с неизвестного устройства', async () => {
		pool.query
			.mockResolvedValueOnce({ rows: [mockUser] }) // поиск пользователя
			.mockResolvedValueOnce({ rows: [{ user_id: mockUser.id, unique_id: 'other-uid' }] }) // другое устройство
		bcrypt.compare.mockResolvedValue(true)

		const result = await userService.login(mockUser.email, 'password', '127.0.0.1', 'UA', uid)

		expect(result).toEqual({ user_sub: mockUser.id })
		expect(tokenService.generateTokens).not.toHaveBeenCalled()
		expect(tokenService.saveToken).not.toHaveBeenCalled()
	})

	it('Ошибка при несуществующем email', async () => {
		pool.query.mockResolvedValueOnce({ rows: [] })

		await expect(userService.login('wrong@examplexample.com', 'pass', '127.0.0.1', 'UA', uid)).rejects.toThrow(ApiError)
		expect(logger.error).toHaveBeenCalledWith(expect.stringContaining('Ошибка при входе'))
	})

	it('Ошибка при неправильном пароле', async () => {
		pool.query.mockResolvedValueOnce({ rows: [mockUser] })
		bcrypt.compare.mockResolvedValue(false)

		await expect(userService.login(mockUser.email, 'wrongpass', '127.0.0.1', 'UA', uid)).rejects.toThrow(ApiError)
		expect(logger.error).toHaveBeenCalledWith(expect.stringContaining('Ошибка при входе'))
	})

	it('Ошибка при внутренних сбоях', async () => {
		pool.query.mockRejectedValue(new Error('error'))

		await expect(userService.login(mockUser.email, 'password', '127.0.0.1', 'UA', uid)).rejects.toThrow(ApiError)
		expect(logger.error).toHaveBeenCalledWith(expect.stringContaining('Ошибка при входе'))
	})
})

describe('prepareNewDevice', () => {
	beforeEach(() => {
		vi.restoreAllMocks()
	})

	it('Успешно генерирует токен и код, отправляет письмо и сохраняет в БД', async () => {
		const userId = 'user-1'
		const email = 'test@examplexample.com'
		const mockToken = 'temp-token'
		tokenService.generateTempToken.mockReturnValue(mockToken)
		pool.query.mockResolvedValue()

		const result = await userService.prepareNewDevice(userId, email)

		expect(tokenService.generateTempToken).toHaveBeenCalledWith(userId)
		expect(pool.query).toHaveBeenCalledWith(expect.stringContaining('INSERT INTO temp_tokens'), expect.any(Array))
		expect(mailService.sendNewDeviceCode).toHaveBeenCalledWith(email, expect.stringMatching(/^[A-Z0-9]{6}$/))
		expect(result).toBe(mockToken)
		expect(logger.info).toHaveBeenCalledWith(expect.stringContaining('Подтверждение нового устройства'))
	})

	it('Обновляет запись при конфликте user_id', async () => {
		const userId = 'user-2'
		const email = 'conflict@examplexample.com'
		tokenService.generateTempToken.mockReturnValue('temp-conflict')
		pool.query.mockResolvedValue()

		await userService.prepareNewDevice(userId, email)

		expect(pool.query).toHaveBeenCalledWith(
			expect.stringContaining('ON CONFLICT (user_id)'),
			expect.arrayContaining([userId, 'temp-conflict'])
		)
	})

	it('Логирует и выбрасывает ошибку при сбое', async () => {
		const userId = 'user-3'
		const email = 'error@examplexample.com'
		tokenService.generateTempToken.mockImplementation(() => { throw new Error('Token gen fail') })

		await expect(userService.prepareNewDevice(userId, email)).rejects.toThrow()

		expect(logger.error).toHaveBeenCalledWith(expect.stringContaining('Ошибка при подтверждении нового устройства'))
	})
})

describe('confirmNewDevice', () => {
	beforeEach(() => {
		vi.restoreAllMocks()
	})

	it('Успешное подтверждение нового устройства', async () => {
		const tempToken = 'temp-token'
		const userId = 'user-123'
		const uniqueId = 'uid-001'
		const userIp = '127.0.0.1'
		const userAgent = 'Mozilla'
		const code = 'ABC123'

		tokenService.validateTempToken.mockReturnValue({ sub: userId })

		pool.query
			.mockResolvedValueOnce({ rows: [{ code }] }) // SELECT code
			.mockResolvedValueOnce({}) // DELETE temp_tokens
			.mockResolvedValueOnce({ rows: [{ role: 'student' }] }) // SELECT * FROM users

		tokenService.generateTokens.mockReturnValue({
			accessToken: 'access',
			refreshToken: 'refresh',
			jti: 'jti-001',
		})

		const result = await userService.confirmNewDevice(code, tempToken, uniqueId, userIp, userAgent)

		expect(tokenService.saveToken).toHaveBeenCalledWith(uniqueId, userId, 'refresh', userIp, userAgent, 'jti-001')
		expect(result).toEqual(expect.objectContaining({
			accessToken: 'access',
			refreshToken: 'refresh',
			sub: userId,
			role: 'student',
		}))
	})

	it('Ошибка при неверном коде', async () => {
		tokenService.validateTempToken.mockReturnValue({ sub: 'user-1' })
		pool.query.mockResolvedValueOnce({ rows: [{ code: 'WRONG' }] })

		await expect(userService.confirmNewDevice('CODE', 'token', 'uid', 'ip', 'agent')).rejects.toThrow(ApiError)
	})

	it('Ошибка при отсутствии записи в temp_tokens', async () => {
		tokenService.validateTempToken.mockReturnValue({ sub: 'user-1' })
		pool.query.mockResolvedValueOnce({ rows: [] })

		await expect(userService.confirmNewDevice('CODE', 'token', 'uid', 'ip', 'agent')).rejects.toThrow(ApiError)
	})

	it('Ошибка при просроченном токене (запись не найдена)', async () => {
		tokenService.validateTempToken.mockReturnValue({ sub: 'user-1' })
		pool.query.mockResolvedValueOnce({ rows: [] })

		await expect(userService.confirmNewDevice('CODE', 'token', 'uid', 'ip', 'agent')).rejects.toThrow(ApiError)
	})

	it('Ошибка при невалидном tempToken', async () => {
		tokenService.validateTempToken.mockImplementation(() => {
			throw new Error('Invalid token')
		})

		await expect(userService.confirmNewDevice('CODE', 'invalid-token', 'uid', 'ip', 'agent')).rejects.toThrow(ApiError)
	})
})

describe('changePassword', () => {
	beforeEach(() => {
		vi.restoreAllMocks()
	})

	it('Успешная смена пароля', async () => {
		const userId = 'user-1'
		const currentPassword = 'oldPass'
		const newPassword = 'newPass'
		const email = 'test@examplexample.com'

		pool.query.mockResolvedValueOnce({ rows: [{ password: 'hashedOld', email }] })
		bcrypt.compare.mockResolvedValue(true)
		bcrypt.hash.mockResolvedValue('hashedNew')
		pool.query.mockResolvedValueOnce({}) // UPDATE

		await userService.changePassword(userId, currentPassword, newPassword)

		expect(bcrypt.compare).toHaveBeenCalledWith(currentPassword, 'hashedOld')
		expect(bcrypt.hash).toHaveBeenCalledWith(newPassword, 10)
		expect(pool.query).toHaveBeenCalledWith(
			expect.stringContaining('UPDATE users SET password'),
			['hashedNew', userId]
		)
		expect(mailService.sendChangePassword).toHaveBeenCalledWith(email, email, newPassword, false)
	})

	it('Ошибка при неверном текущем пароле', async () => {
		pool.query.mockResolvedValueOnce({ rows: [{ password: 'stored' }] })
		bcrypt.compare.mockResolvedValue(false)

		await expect(userService.changePassword('u1', 'wrong', 'new')).rejects.toThrow(ApiError)
	})

	it('Ошибка при исключении из compare', async () => {
		pool.query.mockResolvedValueOnce({ rows: [{ password: 'stored' }] })
		bcrypt.compare.mockRejectedValue(new Error('compare fail'))

		await expect(userService.changePassword('u1', 'curr', 'new')).rejects.toThrow(ApiError)
	})

	it('Ошибка при исключении из pool.query', async () => {
		pool.query.mockRejectedValue(new Error('db fail'))

		await expect(userService.changePassword('u1', 'curr', 'new')).rejects.toThrow(ApiError)
	})
})

describe('changeEmail', () => {
	beforeEach(() => {
		vi.restoreAllMocks()
	})

	it('Успешная смена email', async () => {
		const userId = 'user-1'
		const currentEmail = 'old@examplexample.com'
		const newEmail = 'new@examplexample.com'

		pool.query
			.mockResolvedValueOnce({ rows: [{ email: currentEmail }] }) // проверка текущего email
			.mockResolvedValueOnce({ rows: [] }) // проверка занятости нового email
			.mockResolvedValueOnce({}) // обновление email

		await userService.changeEmail(userId, currentEmail, newEmail)

		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE id = $1', [userId])
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE email = $1', [newEmail])
		expect(pool.query).toHaveBeenCalledWith(
			expect.stringContaining('UPDATE users SET email'),
			[newEmail, userId]
		)
		expect(mailService.sendChangeEmail).toHaveBeenCalledWith(currentEmail, newEmail, false)
		expect(logger.info).toHaveBeenCalledWith(`Email успешно изменён для пользователя: ${userId}`)
	})

	it('Ошибка при неверном текущем email', async () => {
		pool.query.mockResolvedValueOnce({ rows: [{ email: 'wrong@examplexample.com' }] })

		await expect(userService.changeEmail('u1', 'old@examplexample.com', 'new@examplexample.com')).rejects.toThrow(ApiError)
	})

	it('Ошибка если новый email уже существует', async () => {
		pool.query
			.mockResolvedValueOnce({ rows: [{ email: 'old@examplexample.com' }] }) // текущий email совпадает
			.mockResolvedValueOnce({ rows: [{ id: 'user-2' }] }) // новый email занят

		await expect(userService.changeEmail('u1', 'old@examplexample.com', 'old@examplexample.com')).rejects.toThrow(ApiError)
	})

	it('Обработка ошибки при исключении в запросах', async () => {
		pool.query.mockRejectedValue(new Error('error'))

		await expect(userService.changeEmail('u1', 'a', 'b')).rejects.toThrow(ApiError)
	})
})

describe('refresh', () => {
	const ip = '127.0.0.1'
	const agent = 'TestAgent'

	beforeEach(() => {
		vi.restoreAllMocks()
	})

	it('Успешное обновление токенов', async () => {
		const refreshToken = 'valid-token'
		const userId = 'user-1'
		const mockUser = { id: userId, email: 'test@examplexample.com', role: 'USER' }

		tokenService.validateRefreshToken.mockReturnValue({ sub: userId, unique_id: 'device-1' })
		tokenService.findToken.mockResolvedValue({ id: 'token-id' })
		pool.query.mockResolvedValue({ rows: [mockUser] })
		tokenService.generateTokens.mockReturnValue({ accessToken: 'new-access', refreshToken: 'new-refresh' })

		const result = await userService.refresh(refreshToken, ip, agent)

		expect(tokenService.validateRefreshToken).toHaveBeenCalledWith(refreshToken)
		expect(tokenService.findToken).toHaveBeenCalledWith(refreshToken)
		expect(pool.query).toHaveBeenCalledWith('SELECT * FROM users WHERE id = $1', [userId])
		expect(result).toHaveProperty('accessToken')
		expect(result).toHaveProperty('refreshToken')
		expect(result).toHaveProperty('user')
		expect(logger.info).toHaveBeenCalledWith(`Токен успешно обновлен для пользователя: ${userId}`)
	})

	it('Ошибка: невалидный refresh токен', async () => {
		tokenService.validateRefreshToken.mockReturnValue(null)

		await expect(userService.refresh('invalid', ip, agent)).rejects.toThrow(ApiError)
	})

	it('Ошибка: отсутствует токен в БД', async () => {
		tokenService.validateRefreshToken.mockReturnValue({ sub: 'u1' })
		tokenService.findToken.mockResolvedValue(null)

		const result = await userService.refresh('some-token', ip, agent)

		expect(result).toBeUndefined()
	})

	it('Ошибка при исключении', async () => {
		tokenService.validateRefreshToken.mockImplementation(() => { throw new Error('bad') })

		await expect(userService.refresh('x', ip, agent)).rejects.toThrow(ApiError)
	})
})

describe('logout', () => {
	const refreshToken = 'test-refresh-token'

	beforeEach(() => {
		vi.restoreAllMocks()
	})

	it('Успешный выход', async () => {
		await userService.logout(refreshToken)
		expect(tokenService.removeToken).toHaveBeenCalledWith(refreshToken)
		expect(logger.info).toHaveBeenCalledWith('Успешный выход')
	})

	it('Обработка ошибки при выходе', async () => {
		tokenService.removeToken.mockImplementation(() => {
			throw new Error('error')
		})
		await expect(userService.logout(refreshToken)).rejects.toThrow(ApiError)
		expect(logger.error).toHaveBeenCalledWith(expect.stringContaining('Ошибка при выходе'))
	})
})

describe('getProfile', () => {
	beforeEach(() => {
		vi.restoreAllMocks()
	})

	it('Возвращает профиль студента с оценками', async () => {
		pool.query
			.mockResolvedValueOnce({ rows: [{ email: 'stud@mail.ru', role: 'student', first_name: 'Иван', middle_name: 'Иванович', last_name: 'Иванов', student_group_name: 'ПО2-21' }] }) // student info
			.mockResolvedValueOnce({ rows: [{ name: 'Высшая математика' }, { name: 'Физика' }] }) // subjects
			.mockResolvedValueOnce({ rows: [ { subject: 'Высшая математика', grade: 5 }, { subject: 'Высшая математика', grade: 4 }, { subject: 'Физика', grade: null } ] }) // grades

		const result = await userService.getProfile('user-1', 'student')

		expect(result).toEqual({
			user: {
				email: 'stud@mail.ru',
				first_name: 'Иван',
				middle_name: 'Иванович',
				last_name: 'Иванов',
				group: 'ПО2-21'
			},
			averageGrades: [
				{ subject: 'Высшая математика', grade: '4.5' },
				{ subject: 'Физика', grade: null }
			]
		})
	})

	it('Возвращает профиль преподавателя', async () => {
		pool.query
			.mockResolvedValueOnce({ rows: [{ email: 'lect@mail.ru', role: 'lecturer', first_name: 'Анна', middle_name: 'А.', last_name: 'Лектор' }] }) // lecturer info
			.mockResolvedValueOnce({ rows: [{ id: 1, name: 'Физика' }] }) // available subjects
			.mockResolvedValueOnce({ rows: [{ id: 1, name: 'Физика' }] }) // selected subjects
			.mockResolvedValueOnce({ rows: [{ id: 10, name: 'ПО2-21' }] }) // available groups
			.mockResolvedValueOnce({ rows: [{ id: 10, name: 'ПО2-21' }] }) // selected groups

		const result = await userService.getProfile('user-2', 'lecturer')

		expect(result).toEqual({
			user: {
				email: 'lect@mail.ru',
				first_name: 'Анна',
				middle_name: 'А.',
				last_name: 'Лектор'
			},
			availableSubjects: [{ id: 1, name: 'Физика' }],
			selectedSubjects: [{ id: 1, name: 'Физика' }],
			availableGroups: [{ id: 10, name: 'ПО2-21' }],
			selectedGroups: [{ id: 10, name: 'ПО2-21' }]
		})
	})

	it('Обработка ошибки при запросе', async () => {
		pool.query.mockRejectedValue(new Error('error'))
		await expect(userService.getProfile('user-1', 'student')).rejects.toThrow()
	})

	it('Выбрана неподдерживаемая роль — ничего не возвращает', async () => {
		const result = await userService.getProfile('user-unknown', 'admin')
		expect(result).toBeUndefined()
	})

	it('Пользователь не найден — ошибка', async () => {
		pool.query.mockResolvedValueOnce({ rows: [] }) // simulate user not found
		await expect(userService.getProfile('user-missing', 'student')).rejects.toThrow('Внутренняя ошибка сервера')
	})
})

describe('getUsers', () => {
		beforeEach(() => {
		vi.restoreAllMocks()
	})
	it('Успешно возвращает список пользователей с ролями student, lecturer и admin', async () => {
		const mockUsers = [
			{
				id: '1',
				email: 'student@examplexample.com',
				role: 'student',
				first_name: 'Иван',
				middle_name: 'Иванович',
				last_name: 'Иванов',
				group_name: 'АС-21'
			},
			{
				id: '2',
				email: 'lecturer@examplexample.com',
				role: 'lecturer',
				first_name: 'Петр',
				middle_name: 'Петрович',
				last_name: 'Петров',
				group_name: null
			},
			{
				id: '3',
				email: 'admin@examplexample.com',
				role: 'admin',
				first_name: null,
				middle_name: null,
				last_name: null,
				group_name: null
			}
		]

		pool.query.mockResolvedValue({ rows: mockUsers })

		const result = await userService.getUsers()

		expect(pool.query).toHaveBeenCalledTimes(1)
		expect(result).toEqual(mockUsers)
	})

	it('Результат содержит все ожидаемые поля у студента', async () => {
		const mockStudent = {
			id: '1',
			email: 'student@examplexample.com',
			role: 'student',
			first_name: 'Иван',
			middle_name: 'Иванович',
			last_name: 'Иванов',
			group_name: 'АС-21'
		}

		pool.query.mockResolvedValue({ rows: [mockStudent] })

		const result = await userService.getUsers()

		expect(result[0]).toMatchObject({
			id: expect.any(String),
			email: expect.stringContaining('@'),
			role: 'student',
			first_name: 'Иван',
			middle_name: 'Иванович',
			last_name: 'Иванов',
			group_name: 'АС-21'
		})
	})

	it('group_name у преподавателя должен быть null', async () => {
		const mockLecturer = {
			id: '2',
			email: 'lecturer@examplexample.com',
			role: 'lecturer',
			first_name: 'Петр',
			middle_name: 'Петрович',
			last_name: 'Петров',
			group_name: null
		}

		pool.query.mockResolvedValue({ rows: [mockLecturer] })

		const result = await userService.getUsers()
		expect(result[0].role).toBe('lecturer')
		expect(result[0].group_name).toBeNull()
	})

	it('Кидает InternalError при ошибке базы данных', async () => {
		pool.query.mockRejectedValue(new Error('error'))

		await expect(userService.getUsers()).rejects.toThrow('Внутренняя ошибка сервера')
	})
})

describe('searchUsers', () => {
	beforeEach(() => {
	vi.restoreAllMocks()
})
	it('Успешно возвращает список пользователей по совпадению email', async () => {
		const mockUsers = [
			{
				id: '1',
				email: 'student@examplexample.com',
				role: 'student',
				first_name: 'Иван',
				middle_name: 'Иванович',
				last_name: 'Иванов',
				group_name: 'ПО2-21'
			}
		]

		pool.query.mockResolvedValue({ rows: mockUsers })

		const result = await userService.searchUsers('student@examplexample.com')

		expect(pool.query).toHaveBeenCalledWith(expect.stringContaining('ILIKE'), ['%student@examplexample.com%'])
		expect(result).toEqual(mockUsers)
	})

	it('Успешно возвращает пользователей по совпадению имени/фамилии/отчества', async () => {
		const mockLecturer = [
			{
				id: '2',
				email: 'lecturer@examplexample.com',
				role: 'lecturer',
				first_name: 'Петр',
				middle_name: 'Сергеевич',
				last_name: 'Петров',
				group_name: null
			}
		]

		pool.query.mockResolvedValue({ rows: mockLecturer })

		const result = await userService.searchUsers('Петр')

		expect(pool.query).toHaveBeenCalledWith(expect.stringContaining('ILIKE'), ['%Петр%'])
		expect(result).toEqual(mockLecturer)
	})

	it('Возвращает пустой массив, если нет совпадений', async () => {
		pool.query.mockResolvedValue({ rows: [] })

		const result = await userService.searchUsers('несуществующий')

		expect(pool.query).toHaveBeenCalledTimes(1)
		expect(result).toEqual([])
	})

it('Ошибка при запросе к БД', async () => {
	pool.query.mockRejectedValue(new Error('error'))

	await expect(userService.searchUsers('тест')).rejects.toThrow('Внутренняя ошибка сервера') 
})

})

describe('updateUser', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  const student = { rows: [{ role: 'student', email: 'stu@example.com' }] }
  const lecturer = { rows: [{ role: 'lecturer', email: 'lect@example.com' }] }
  const admin    = { rows: [{ role: 'admin',    email: 'adm@example.com' }] }

  it('Успешно обновляет email студента', async () => {
    pool.query
      .mockResolvedValueOnce({})        // BEGIN
      .mockResolvedValueOnce(student)   // SELECT role,email
      .mockResolvedValueOnce({}) // UPDATE users
      .mockResolvedValueOnce({})        // COMMIT

    await userService.updateUser('1', { email: 'new@example.com' }, '1')

    expect(pool.query).toHaveBeenCalledWith(expect.stringContaining('UPDATE users SET'), expect.any(Array))
    expect(mailService.sendChangeEmail).toHaveBeenCalledWith('stu@example.com', 'new@example.com', true)
    expect(pool.query).toHaveBeenCalledWith('COMMIT')
  })

  it('Успешно сбрасывает пароль студента', async () => {
    bcrypt.hash.mockResolvedValue('hpass')
    pool.query
      .mockResolvedValueOnce({})      // BEGIN
      .mockResolvedValueOnce(student) // SELECT role,email
      .mockResolvedValueOnce({})      // UPDATE users
      .mockResolvedValueOnce({})      // COMMIT

    await userService.updateUser('1', { resetPassword: true }, '1')

    expect(bcrypt.hash).toHaveBeenCalled()
    expect(mailService.sendChangePassword).toHaveBeenCalledWith(
      'stu@example.com', 'stu@example.com', expect.any(String), true
    )
    expect(pool.query).toHaveBeenCalledWith('COMMIT')
  })

  it('Обновляет ФИО у преподавателя', async () => {
    pool.query
      .mockResolvedValueOnce({})       // BEGIN
      .mockResolvedValueOnce(lecturer) // SELECT role,email
      .mockResolvedValueOnce({})       // UPDATE lecturers
      .mockResolvedValueOnce({})       // COMMIT

    await userService.updateUser('2', { first_name: 'Мария', middle_name: "Ивановна", last_name: 'Смирнова' }, '2')

    expect(pool.query).toHaveBeenCalledWith(expect.stringContaining('UPDATE lecturers SET'), expect.any(Array))
    expect(pool.query).toHaveBeenCalledWith('COMMIT')
  })

  it('Обновляет группу студента при валидной группе', async () => {
    pool.query
      .mockResolvedValueOnce({})                    // BEGIN
      .mockResolvedValueOnce(student)               // SELECT role,email
      .mockResolvedValueOnce({ rowCount: 1, rows: [{ id: 42 }] }) // SELECT group
      .mockResolvedValueOnce({})                    // UPDATE students
      .mockResolvedValueOnce({})                    // COMMIT

    await expect(userService.updateUser('1', { group_name: 'A' }, '1')).resolves.not.toThrow()
    expect(pool.query).toHaveBeenCalledWith(expect.stringContaining('UPDATE students SET'), expect.any(Array))
    expect(pool.query).toHaveBeenCalledWith('COMMIT')
  })

  it('Ошибка если группа не найдена', async () => {
    pool.query
      .mockResolvedValueOnce({})      // BEGIN
      .mockResolvedValueOnce(student) // SELECT role,email
      .mockResolvedValueOnce({rowCount: 0}) // SELECT group

    await expect(userService.updateUser('1', { group_name: 'ПО1-21' }, '1'))
      .rejects.toThrow('Группа с названием "ПО1-21" не найдена')
    expect(pool.query).toHaveBeenCalledWith('ROLLBACK')
  })

  it('Запрещает обновлять другого admin', async () => {
    pool.query
      .mockResolvedValueOnce({})  // BEGIN
      .mockResolvedValueOnce(admin) // SELECT role,email

    await expect(userService.updateUser('1', { email: 'x@x.com' }, '2'))
      .rejects.toThrow('Нельзя изменить данные у admin')
    expect(pool.query).toHaveBeenCalledWith('ROLLBACK')
  })

  it('Вызывает ROLLBACK при общей ошибке', async () => {
    pool.query
      .mockResolvedValueOnce({})      // BEGIN
      .mockResolvedValueOnce(student) // SELECT role,email
      .mockRejectedValueOnce(new Error('oops')) // UPDATE users

    await expect(userService.updateUser('1', { email: 'y@y.com' }, '1'))
      .rejects.toThrow('Внутренняя ошибка сервера')
    expect(pool.query).toHaveBeenCalledWith('ROLLBACK')
  })
})

describe('deleteUser', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('Успешно удаляет пользователя', async () => {
    pool.query.mockResolvedValueOnce({}) // Успешный DELETE

    await expect(userService.deleteUser('1')).resolves.toBeUndefined()

    expect(pool.query).toHaveBeenCalledWith(
      'DELETE FROM users WHERE id = $1',
      ['1']
    )
    expect(logger.info).toHaveBeenCalledWith('Удаление пользователя: 1')
    expect(logger.info).toHaveBeenCalledWith('Пользователь успешно удален: 1')
  })

  it('Ошибка при запросе к БД', async () => {
    pool.query.mockRejectedValueOnce(new Error('error'))

    await expect(userService.deleteUser('1')).rejects.toThrow(ApiError)

    expect(logger.error).toHaveBeenCalledWith(expect.stringContaining('Ошибка при удалении пользователя: error'))
  })
})

describe('updateSubjects', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('Успешно обновляет предметы пользователя', async () => {
    const userId = '123'
    const subjects = [1, 2]
    pool.query
      .mockResolvedValueOnce({})              // BEGIN
      .mockResolvedValueOnce({})              // DELETE
    for (const id of subjects) {
      pool.query.mockResolvedValueOnce({ rows: [{ id }] })  // SELECT предмета
      pool.query.mockResolvedValueOnce({})                  // INSERT
    }
    pool.query.mockResolvedValueOnce({})                    // COMMIT

    await expect(userService.updateSubjects(userId, subjects)).resolves.toBeUndefined()

    expect(pool.query).toHaveBeenNthCalledWith(1, 'BEGIN')
    expect(pool.query).toHaveBeenNthCalledWith(2, 'DELETE FROM lecturer_subjects WHERE lecturer_id = $1', [userId])
    expect(pool.query).toHaveBeenNthCalledWith(3, 'SELECT id FROM subjects WHERE id = $1', [1])
    expect(pool.query).toHaveBeenNthCalledWith(4, expect.stringContaining('INSERT INTO lecturer_subjects'), [userId, 1])
    expect(pool.query).toHaveBeenNthCalledWith(5, 'SELECT id FROM subjects WHERE id = $1', [2])
    expect(pool.query).toHaveBeenNthCalledWith(6, expect.stringContaining('INSERT INTO lecturer_subjects'), [userId, 2])
    expect(pool.query).toHaveBeenNthCalledWith(7, 'COMMIT')
  })

 it('Ошибка если предмет не найден', async () => {
    const userId = '123'
    const invalidSubjectId = 999
    const subjects = [invalidSubjectId]
    pool.query.mockResolvedValueOnce({}) 
    pool.query.mockResolvedValueOnce({})
    pool.query.mockResolvedValueOnce({ rows: [] })
    await expect(userService.updateSubjects(userId, subjects))
      .rejects.toThrow(`Предмет с ID ${invalidSubjectId} не найден`)
    expect(pool.query).toHaveBeenCalledWith('ROLLBACK')
  })

  it('Вызывает ROLLBACK при ошибке БД', async () => {
    const userId = '123'
    const subjects = [1]

    pool.query
      .mockResolvedValueOnce({})              // BEGIN
      .mockRejectedValueOnce(new Error('error'))  // Ошибка при DELETE

    await expect(userService.updateSubjects(userId, subjects))
      .rejects.toThrow('Внутренняя ошибка сервера')

    expect(pool.query).toHaveBeenCalledWith('ROLLBACK')
  })
})

describe('updateGroups', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('Успешно обновляет группы пользователя', async () => {
    const userId = '123'
    const groups = [10, 20]

    pool.query
      .mockResolvedValueOnce({})              // BEGIN
      .mockResolvedValueOnce({})              // DELETE

    for (const id of groups) {
      pool.query.mockResolvedValueOnce({ rows: [{ id }] })  // SELECT группы
      pool.query.mockResolvedValueOnce({})                  // INSERT
    }

    pool.query.mockResolvedValueOnce({})                    // COMMIT

    await expect(userService.updateGroups(userId, groups)).resolves.toBeUndefined()

    expect(pool.query).toHaveBeenNthCalledWith(1, 'BEGIN')
    expect(pool.query).toHaveBeenNthCalledWith(2, 'DELETE FROM lecturer_groups WHERE lecturer_id = $1', [userId])
    expect(pool.query).toHaveBeenNthCalledWith(3, 'SELECT id FROM groups WHERE id = $1', [10])
    expect(pool.query).toHaveBeenNthCalledWith(4, expect.stringContaining('INSERT INTO lecturer_groups'), [userId, 10])
    expect(pool.query).toHaveBeenNthCalledWith(5, 'SELECT id FROM groups WHERE id = $1', [20])
    expect(pool.query).toHaveBeenNthCalledWith(6, expect.stringContaining('INSERT INTO lecturer_groups'), [userId, 20])
    expect(pool.query).toHaveBeenNthCalledWith(7, 'COMMIT')
  })

  it('Ошибка если группа не найдена', async () => {
    const userId = '123'
    const invalidGroupId = 999
    const groups = [invalidGroupId]

    pool.query.mockResolvedValueOnce({})  // BEGIN
    pool.query.mockResolvedValueOnce({})  // DELETE
    pool.query.mockResolvedValueOnce({ rows: [] })  // SELECT группы (не найдена)

    await expect(userService.updateGroups(userId, groups))
      .rejects.toThrow(`Группа с ID ${invalidGroupId} не найдена`)

    expect(pool.query).toHaveBeenCalledWith('ROLLBACK')
  })

  it('Вызывает ROLLBACK при ошибке БД', async () => {
    const userId = '123'
    const groups = [10]

    pool.query
      .mockResolvedValueOnce({})               // BEGIN
      .mockRejectedValueOnce(new Error('error'))  // Ошибка при DELETE

    await expect(userService.updateGroups(userId, groups))
      .rejects.toThrow('Внутренняя ошибка сервера')

    expect(pool.query).toHaveBeenCalledWith('ROLLBACK')
  })
})

describe('quitSessions', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('Успешно завершает все сессии пользователя', async () => {
    const userId = '123'

    pool.query.mockResolvedValueOnce({})  // UPDATE tokens

    await expect(userService.quitSessions(userId)).resolves.toBeUndefined()

    expect(pool.query).toHaveBeenCalledWith(
      'UPDATE tokens SET is_revoked = TRUE WHERE user_id = $1',
      [userId]
    )
  })

  it('Ошибка при запросе к БД', async () => {
    const userId = '123'

    pool.query.mockRejectedValueOnce(new Error('error'))

    await expect(userService.quitSessions(userId))
      .rejects.toThrow('Внутренняя ошибка сервера')

    expect(pool.query).toHaveBeenCalledWith(
      'UPDATE tokens SET is_revoked = TRUE WHERE user_id = $1',
      [userId]
    )
  })
})
