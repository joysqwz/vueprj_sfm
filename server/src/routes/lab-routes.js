import { Router } from 'express'
import labController from '../controllers/lab-controller.js'
import { roleMiddleware } from '../middlewares/role-middleware.js'
import { authMiddleware } from '../middlewares/auth-middleware.js'
import { upload, reportUpload } from '../config/multer.js'

const router = Router()


router.get(
	'/labs', authMiddleware,
	labController.getLabsByUser
)
router.get('/labs/:id', authMiddleware, labController.getLabDetails)
router.post(
	'/labs',
	roleMiddleware(['lecturer']),
	upload.array('files', 10),
	labController.createLab
)
router.put(
	'/labs/:id',
	authMiddleware,
	roleMiddleware(['lecturer']),
	upload.array('files', 10),
	labController.updateLab
)
router.delete(
	'/labs/:id',
	authMiddleware,
	roleMiddleware(['lecturer', 'admin']),
	labController.removeLab
)

router.get('/admin/labs', roleMiddleware(['admin']), labController.getAllLabs)
router.get('/admin/labs/search', roleMiddleware(['admin']), labController.searchLabs)

router.patch(
	'/labs/:labId/student/:userId/grade',
	roleMiddleware(['lecturer']),
	labController.updateStudentGrade
)

router.get(
	'/labs/lecturers/:lecturerId/subjects',
	roleMiddleware(['lecturer']),
	labController.getSubjectsByLecturer
)

router.get(
	'/labs/lecturers/:lecturerId/subjects/:subjectId/groups',
	roleMiddleware(['lecturer', 'admin']),
	labController.getGroupsBySubject
)

router.get(
	'/labs/lecturers/:lecturerId/subjects/:subjectId/groups/:groupId/students',
	authMiddleware,
	roleMiddleware(['lecturer', 'admin']),
	labController.getStudentsByGroupAndSubject
)

router.get(
	'/labs/lecturer/:lecturerId/groups-subjects',
	roleMiddleware(['lecturer', 'admin']),
	labController.getGroupsAndSubjectsByLecturer
)

router.get('/labs/files/:filename', authMiddleware, labController.downloadLabFile)
router.post(
	'/labs/:labId/submission',
	authMiddleware,
	reportUpload.array('submissions', 10),
	labController.uploadSubmission
)

router.get('/submissions/files/:filename', authMiddleware, labController.downloadSubmissionFile)

export default router