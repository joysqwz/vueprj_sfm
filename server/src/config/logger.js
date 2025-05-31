import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const logsDir = path.join(__dirname, '../../logs')
if (!fs.existsSync(logsDir)) {
	fs.mkdirSync(logsDir)
}

const colors = {
	reset: '\x1b[0m',
	bright: '\x1b[1m',
	dim: '\x1b[2m',
	red: '\x1b[31m',
	green: '\x1b[32m',
	yellow: '\x1b[33m',
	blue: '\x1b[34m',
	magenta: '\x1b[35m',
	cyan: '\x1b[36m',
	white: '\x1b[37m'
}

function formatDate() {
	const date = new Date()
	return date.toISOString()
}

function formatMessage(level, message, meta = {}) {
	const timestamp = formatDate()
	const decodedMessage = decodeURIComponent(message)
	const metaString = Object.keys(meta).length ? `\n${JSON.stringify(meta, null, 2)}` : ''
	return `[${timestamp}] ${level}: ${decodedMessage}${metaString}\n`
}

function writeToFile(level, message, meta = {}) {
	const logFile = level === 'ERROR' ? 'error.log' : 'combined.log'
	const logPath = path.join(logsDir, logFile)
	const logMessage = formatMessage(level, message, meta)

	fs.appendFileSync(logPath, logMessage)
}

function writeToConsole(level, message, meta = {}) {
	const color = {
		INFO: colors.green,
		WARN: colors.yellow,
		ERROR: colors.red,
		DEBUG: colors.blue
	}[level] || colors.white

	const logMessage = formatMessage(level, message, meta)
	console.log(color + logMessage + colors.reset)
}

class Logger {
	info(message, meta = {}) {
		writeToFile('INFO', message, meta)
		writeToConsole('INFO', message, meta)
	}

	warn(message, meta = {}) {
		writeToFile('WARN', message, meta)
		writeToConsole('WARN', message, meta)
	}

	error(message, meta = {}) {
		writeToFile('ERROR', message, meta)
		writeToConsole('ERROR', message, meta)
	}

	debug(message, meta = {}) {
		if (process.env.NODE_ENV === 'development') {
			writeToFile('DEBUG', message, meta)
			writeToConsole('DEBUG', message, meta)
		}
	}
}

export default new Logger()