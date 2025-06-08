import multer from "multer"
import path from "path"
import { fileURLToPath } from "url"
import mime from 'mime-types'
import { ApiError } from '../exceptions/api-error.js'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const storage = multer.diskStorage({
	destination: (req, file, cb) => {
		const uploadPath = path.join(__dirname, '../../uploads/labs')
		cb(null, uploadPath)
	},
	filename: (req, file, cb) => {
		const originalName = Buffer.from(file.originalname, 'latin1').toString('utf8')
		const uniqueSuffix = Date.now()
		const ext = path.extname(originalName)
		const baseName = path.basename(originalName, ext)
		const fileName = `${baseName}-${uniqueSuffix}${ext}`
		cb(null, fileName)
	}
})

const reportStorage = multer.diskStorage({
	destination: (req, file, cb) => {
		const uploadPath = path.join(__dirname, '../../uploads/submissions')
		cb(null, uploadPath)
	},
	filename: (req, file, cb) => {
		const originalName = Buffer.from(file.originalname, 'latin1').toString('utf8')
		const uniqueSuffix = Date.now()
		const ext = path.extname(originalName)
		const baseName = path.basename(originalName, ext)
		const fileName = `${baseName}-${uniqueSuffix}${ext}`
		cb(null, fileName)
	}
})

const fileFilter = (req, file, cb) => {
	const allowedExtensions = ['pdf', 'doc', 'docx']
	const ext = mime.extension(file.mimetype)

	if (allowedExtensions.includes(ext)) {
		cb(null, true)
	} else {
		const error = new ApiError(400, 'Недопустимый тип файла. Разрешены только .pdf, .doc, .docx')
		error.code = 'LIMIT_FILE_TYPE'
		cb(error, false)
	}
}

export const reportUpload = multer({
	storage: reportStorage,
	fileFilter: fileFilter,
	limits: { fileSize: 10 * 1024 * 1024 }
})

export const upload = multer({
	storage: storage,
	limits: { fileSize: 10 * 1024 * 1024 }
})