import labService from '../service/lab-service.js'
import path from 'path'
import { fileURLToPath } from 'url'
import mime from 'mime-types'
import { ApiError } from '../exceptions/api-error.js'

class LabController {
	async createLab(req, res, next) {
		try {
			const lecturer = req.user.sub
			const { title, group, description, subject } = req.body
			const files = req.files || []
			const fileNames = files.map(file => file.filename)
			const filePaths = files.map(file => file.path)

			const labData = await labService.createLab(lecturer, title, group, description, fileNames, filePaths, subject)
			return res.json({ message: 'ЛБ создана', id: labData.id, created: labData.created })
		} catch (error) {
			next(error)
		}
	}

	async getLabsByUser(req, res, next) {
		try {
			const userId = req.user.sub
			const userRole = req.user.role
			const labs = await labService.getLabsByUser(userId, userRole)
			return res.json({ labs })
		} catch (error) {
			next(error)
		}
	}

	async getLabDetails(req, res, next) {
		try {
			const { id } = req.params
			const userRole = req.user.role
			const userId = req.user.sub
			const lab = await labService.getLabDetails(id, userId, userRole)
			if (!lab) {
				throw ApiError.NotFound('Лабораторная работа не найдена')
			}
			if (userRole === 'student') {
				delete lab.groups
			}
			const responseData = { lab }
			if (userRole !== 'student') {
				const students = await labService.getStudentsByLab(id)
				responseData.students = students
			} else {
				const submission = await labService.getStudentSubmission(id, userId)
				responseData.student_submission = submission
					? { file_names: submission.files }
					: null
			}
			return res.json(responseData)
		} catch (error) {
			next(error)
		}
	}

	async updateLab(req, res, next) {
		try {
			const __filename = fileURLToPath(import.meta.url)
			const __dirname = path.dirname(__filename)
			const projectRoot = path.resolve(__dirname, '../../')
			const { id } = req.params
			const { title, description, existingFiles, deleteAllFiles } = req.body
			const newFiles = req.files || []
			let existingFileNames = []
			if (existingFiles) {
				if (Array.isArray(existingFiles)) {
					existingFileNames = existingFiles
				} else if (typeof existingFiles === 'string') {
					try {
						existingFileNames = JSON.parse(existingFiles)
					} catch (err) {
						console.error('Ошибка парсинга existingFiles:', err)
						existingFileNames = [existingFiles]
					}
				}
			}
			const updatedLabData = {}
			if (title) updatedLabData.title = title
			if (description) updatedLabData.description = description
			updatedLabData.files = [
				...existingFileNames.map(fileName => ({
					file_name: fileName,
					file_path: path.join(projectRoot, 'uploads/labs', fileName)
				})),
				...newFiles.map(file => ({
					file_name: file.filename,
					file_path: path.join(projectRoot, 'uploads/labs', file.filename)
				}))
			]
			const result = await labService.updateLab(id, updatedLabData, deleteAllFiles === 'true')
			return res.json({
				message: 'ЛБ успешно обновлена',
				files: result.files
			})
		} catch (error) {
			next(error)
		}
	}

	async removeLab(req, res, next) {
		try {
			const { id } = req.params
			await labService.deleteLab(id)
			return res.json({ message: 'Лабораторная работа удалена' })
		} catch (error) {
			next(error)
		}
	}

	async getAllLabs(req, res, next) {
		try {
			const labs = await labService.getAllLabs()
			return res.json({ labs })
		} catch (error) {
			next(error)
		}
	}

	async searchLabs(req, res, next) {
		try {
			const { query } = req.query
			if (!query) {
				return res.json([])
			}
			const labs = await labService.searchLabs(query)
			return res.json({ labs })
		} catch (error) {
			next(error)
		}
	}

	async updateStudentGrade(req, res, next) {
		try {
			const { labId, userId } = req.params
			const { grade } = req.body
			const lab = await labService.getLabDetails(labId)
			if (!lab) {
				throw ApiError.NotFound({ message: 'Лабораторная работа не найдена' })
			}
			const validGrades = [0, 1, 2]
			const parsedGrade = parseInt(grade, 10)
			if (!validGrades.includes(parsedGrade)) {
				throw ApiError.BadRequest({ message: 'Оценка должна быть 0, 1 или 2' })
			}
			const updated = await labService.updateStudentGrade(labId, userId, parsedGrade)
			if (!updated) {
				throw ApiError.NotFound({ message: 'Студент не найден' })
			}
			return res.json({ message: 'Оценка обновлена' })
		} catch (error) {
			next(error)
		}
	}

	async getSubjectsByLecturer(req, res, next) {
		try {
			const { lecturerId } = req.params
			const subjects = await labService.getSubjectsByLecturer(lecturerId)
			return res.json({ subjects })
		} catch (error) {
			next(error)
		}
	}

	async getGroupsBySubject(req, res, next) {
		try {
			const { lecturerId, subjectId } = req.params
			const groups = await labService.getGroupsBySubject(lecturerId, subjectId)
			return res.json({ groups })
		} catch (error) {
			next(error)
		}
	}

	async getStudentsByGroupAndSubject(req, res, next) {
		try {
			const { groupId, subjectId, lecturerId } = req.params
			const students = await labService.getStudentsByGroupAndSubject(groupId, subjectId, lecturerId)
			return res.json({ students })
		} catch (error) {
			next(error)
		}
	}

	async getGroupsAndSubjectsByLecturer(req, res, next) {
		try {
			const { lecturerId } = req.params
			const result = await labService.getGroupsAndSubjectsByLecturer(lecturerId)
			return res.json(result)
		} catch (error) {
			next(error)
		}
	}

	async downloadLabFile(req, res, next) {
		try {
			const { filename } = req.params
			const { exists, filePath } = await labService.downloadFile(filename)
			if (!exists) {
				return res.status(404).json({ message: 'Файл не найден' })
			}
			const mimeType = mime.lookup(filePath)
			const previewable = ['pdf', 'png', 'jpg', 'jpeg', 'gif', 'txt', 'html']
			const ext = (filename.split('.').pop() || '').toLowerCase()
			if (previewable.includes(ext)) {
				const encodedFilename = encodeURIComponent(filename)
				res.setHeader('Content-Type', mimeType || 'application/octet-stream')
				res.setHeader('Content-Disposition', `inline; filename*=UTF-8''${encodedFilename}`)
				res.sendFile(filePath)
			} else {
				res.download(filePath)
			}
		} catch (error) {
			next(error)
		}
	}

	async uploadSubmission(req, res, next) {
		try {
			const { labId } = req.params
			const userId = req.user.sub
			const files = req.files || []
			if (!files.length) {
				throw ApiError.BadRequest({ message: 'Необходимо загрузить хотя бы один файл' })
			}
			const fileNames = files.map(file => file.filename)
			const filePaths = files.map(file => file.path)
			const updatedSubmission = await labService.uploadSubmission(labId, userId, fileNames, filePaths)
			return res.json({ submission_files: updatedSubmission.files })
		} catch (error) {
			next(error)
		}
	}

	async downloadSubmissionFile(req, res, next) {
		try {
			const { filename } = req.params
			const { exists, filePath } = await labService.downloadSubmissionFile(filename)
			if (!exists) {
				throw ApiError.NotFound({ message: 'Файл отчёта не найден' })
			}
			const mimeType = mime.lookup(filePath)
			const previewable = ['pdf', 'png', 'jpg', 'jpeg', 'gif', 'txt', 'html']
			const ext = (filename.split('.').pop() || '').toLowerCase()
			if (previewable.includes(ext)) {
				const encodedFilename = encodeURIComponent(filename)
				res.setHeader('Content-Type', mimeType || 'application/octet-stream')
				res.setHeader('Content-Disposition', `inline; filename*=UTF-8''${encodedFilename}`)
				res.sendFile(filePath)
			} else {
				res.download(filePath)
			}
		} catch (error) {
			next(error)
		}
	}

}

export default new LabController()