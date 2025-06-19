import nodemailer from 'nodemailer'
import logger from '../config/logger.js'
import dotenv from 'dotenv'
dotenv.config()

class MailService {
	constructor() {
		this.transporter = nodemailer.createTransport({
			host: 'smtp.mail.ru',
			port: 465,
			secure: true,
			auth: {
				user: process.env.SMTP_USER || '',
				pass: process.env.SMTP_PASSWORD || ''
			}
		})
	}

	async sendInfoUser(to, email, password) {
		const mailOptions = {
			from: `"СУЛБ" <${process.env.SMTP_USER}>`,
			to,
			subject: `Информация о аккаунте`,
			html: `
				<div>
					<h1>Вы были зарегистрированы в СУЛБ</h1>
					<p style="font-size: 18px; margin: 0;">Логин: ${email}</p>
					<p style="font-size: 18px; margin: 0;">Пароль: ${password}</p>
					<p style="font-size: 12px; margin-top: 10px; color: #ccc !important;">
						<a href="https://vueprj-sfmeied.ru" target="_blank" rel="noopener noreferrer" style="color: #ddd !important; text-decoration: none !important;">vueprj-sfmeied.ru</a>
					</p>
				</div>
			`,
		}

		try {
			await this.transporter.sendMail(mailOptions)
			logger.info(`Письмо успешно отправлено на: ${to}`)
		} catch (err) {
			logger.error(`Ошибка отправки письма на ${to}: ${err.message}`)
			throw err
		}
	}

	// Аналогично можно сделать и другие методы:
	async sendChangePassword(to, email, newPassword, isAdmin) {
		const mailOptions = {
			from: `"СУЛБ" <${process.env.SMTP_USER}>`,
			to,
			subject: `Изменение пароля`,
			html: `
				<div>
					<p style="font-size: 18px; margin: 0;">Логин: ${email}</p>
					<p style="font-size: 18px; margin: 0;">Новый пароль: ${newPassword}</p>
					${isAdmin ? '<p style="font-size: 16px; color: #888;">Пароль был изменён администратором</p>' : ''}
					<p style="font-size: 12px; margin-top: 10px; color: #ccc !important;">
						<a href="https://vueprj-sfmeied.ru" target="_blank" rel="noopener noreferrer" style="color: #ddd !important; text-decoration: none !important;">vueprj-sfmeied.ru</a>
					</p>
				</div>
			`
		}

		try {
			await this.transporter.sendMail(mailOptions)
			logger.info(`Пароль отправлен на почту: ${to}`)
		} catch (err) {
			logger.error(`Ошибка при отправке письма смены пароля на ${to}: ${err.message}`)
			throw err
		}
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
