import express from "express"
import cors from "cors"
import dotenv from "dotenv"
import cookieParser from 'cookie-parser'

import userRoutes from "./routes/user-routes.js"
import labRoutes from "./routes/lab-routes.js"
import grpSubjRoutes from "./routes/grp-subj-routes.js"
import { errorMiddleware } from './middlewares/error-middleware.js'
import table from './data/table.js'
import logger from './config/logger.js'
dotenv.config()

const PORT = process.env.PORT || 3001
const app = express()
app.set('trust proxy', true)

app.use(express.json())
app.use(cookieParser())
app.use(cors({
	credentials: true,
	origin: process.env.CLIENT_URL
}))

app.use((req, res, next) => {
	logger.info(`${req.method} ${req.url}`, {
		ip: req.ip,
		userAgent: req.get('user-agent')
	})
	next()
})

app.use("/api", userRoutes, labRoutes, grpSubjRoutes)
app.use(errorMiddleware)

table.create()
// table.delete()

const start = () => {
	try {
		app.listen(PORT, () => {
			logger.info(`Сервер запущен на порту ${PORT}`)
		})
	} catch (e) {
		logger.error('Ошибка при запуске сервера:', { error: e.message })
		process.exit(1)
	}
}

start()