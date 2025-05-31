import nodemailer from 'nodemailer'
import logger from '../config/logger.js'
import dotenv from 'dotenv'
dotenv.config()

class MailService {
	constructor() {
		this.transporter = nodemailer.createTransport({
			host: 'smtp.yandex.ru',
			port: 465,
			secure: true,
			pool: true,
			maxConnections: 5,
			rateLimit: 1,
			auth: {
				user: process.env.SMTP_USER || '',
				pass: process.env.SMTP_PASSWORD || ''
			}
		})

		this.queue = []
		this.sending = false
		this.delay = 500
	}

	addToQueue(mailOptions) {
		this.queue.push(mailOptions)
		this.processQueue()
	}

	async processQueue() {
		if (this.sending || this.queue.length === 0) return
		this.sending = true

		while (this.queue.length > 0) {
			const mail = this.queue.shift()

			try {
				await this.transporter.sendMail(mail)
				logger.info(`Письмо успешно отправлено на: ${mail.to}`)
			} catch (err) {
				logger.error(`Ошибка отправки письма на ${mail.to}: ${err.message}`)
			}

			await new Promise(res => setTimeout(res, this.delay))
		}

		this.sending = false
	}

	sendInfoUser(to, email, password) {
		this.addToQueue({
			from: `"СУЛБ" <${process.env.SMTP_USER}>`,
			to,
			subject: `Информация о аккаунте`,
			html: `
				<div>
					<h1>Вы были зарегистрированы в СУЛБ</h1>
					<p style="font-size: 18px; margin: 0;">Логин: ${email}</p>
					<p style="font-size: 18px; margin: 0;">Пароль: ${password}</p>
					<p style="font-size: 12px; margin-top: 10px; color: #ccc !important;">
					<a href="https://vueprj-sfmeied.ru" target="_blank" rel="noopener noreferrer" style="color: #ddd !important; text-decoration: none !important; ">vueprj-sfmeied.ru</a>
					</p>
				</div>
			`,
		})
	}

	sendChangePassword(to, email, newPassword, isAdmin) {
		this.addToQueue({
			from: `"СУЛБ" <${process.env.SMTP_USER}>`,
			to,
			subject: `Изменение пароля`,
			html: `
				<div>
					<p style="font-size: 18px; margin: 0;">Логин: ${email}</p>
					<p style="font-size: 18px; margin: 0;">Новый пароль: ${newPassword}</p>
					${isAdmin ? '<p style="font-size: 16px; color: #888;">Пароль был изменён администратором</p>' : ''}
					<p style="font-size: 12px; margin-top: 10px; color: #ccc !important;">
					<a href="https://vueprj-sfmeied.ru" target="_blank" rel="noopener noreferrer" style="color: #ddd !important; text-decoration: none !important; ">vueprj-sfmeied.ru</a>
					</p>
				</div>
			`,
		})
	}


	sendChangeEmail(to, newEmail, isAdmin) {
		const maskedEmail = this.maskEmail(newEmail)

		this.addToQueue({
			from: `"СУЛБ" <${process.env.SMTP_USER}>`,
			to,
			subject: `Изменение почты`,
			html: `
				<div>
					<p style="font-size: 18px; margin: 0;">Новая почта: ${maskedEmail}</p>
					${isAdmin ? '<p style="font-size: 16px; color: #888;">Почта была изменена администратором</p>' : ''}
					<p style="font-size: 12px; margin-top: 10px; color: #ccc !important;">
					<a href="https://vueprj-sfmeied.ru" target="_blank" rel="noopener noreferrer" style="color: #ddd !important; text-decoration: none !important; ">vueprj-sfmeied.ru</a>
					</p>
				</div>
			`,
		})

		this.addToQueue({
			from: `"СУЛБ" <${process.env.SMTP_USER}>`,
			to: newEmail,
			subject: `Изменение почты`,
			html: `
				<div>
					<h1>Активирована новая почта для вашего аккаунта</h1>
					${isAdmin ? '<p style="font-size: 16px; color: #888;">Почта была изменена администратором</p>' : ''}
					<p style="font-size: 12px; margin-top: 10px; color: #ccc !important;">
					<a href="https://vueprj-sfmeied.ru" target="_blank" rel="noopener noreferrer" style="color: #ddd !important; text-decoration: none !important; ">vueprj-sfmeied.ru</a>
					</p>
				</div>
			`,
		})
	}


	sendNewDeviceCode(to, code) {
		this.addToQueue({
			from: `"СУЛБ" <${process.env.SMTP_USER}>`,
			to,
			subject: `Подтверждение входа`,
			html: `
				<div>
					<p style="font-size: 18px; margin: 0;">Введите код подтверждения: ${code}</p>
					<p style="font-size: 12px; margin-top: 10px; color: #ccc !important;">
					<a href="https://vueprj-sfmeied.ru" target="_blank" rel="noopener noreferrer" style="color: #ddd !important; text-decoration: none !important; ">vueprj-sfmeied.ru</a>
					</p>
				</div>
			`,
		})
	}

	maskEmail(email) {
		const [local, domain] = email.split('@')
		const mask = (str) =>
			str.length <= 2 ? '*'.repeat(str.length) : str[0] + '*'.repeat(str.length - 2) + str[str.length - 1]

		const maskedLocal = mask(local)
		const [domainName, ...rest] = domain.split('.')
		const maskedDomain = mask(domainName) + (rest.length ? '.' + rest.join('.') : '')

		return `${maskedLocal}@${maskedDomain}`
	}

}

export default new MailService()
