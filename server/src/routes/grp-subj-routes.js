import { Router } from 'express'
import { roleMiddleware } from '../middlewares/role-middleware.js'
import GrpSubjController from "../controllers/grp-subj-controller.js"

const router = Router()
router.get('/admin/groups', roleMiddleware('admin'), GrpSubjController.getAllGroups)
router.put('/admin/groups/:id', roleMiddleware('admin'), GrpSubjController.updateGroup)
router.post('/admin/groups', roleMiddleware('admin'), GrpSubjController.addGroup)
router.delete('/admin/groups/:id', roleMiddleware('admin'), GrpSubjController.deleteGroup)

router.get('/admin/subjects', roleMiddleware('admin'), GrpSubjController.getAllSubjects)
router.put('/admin/subjects/:id', roleMiddleware('admin'), GrpSubjController.updateSubject)
router.post('/admin/subjects', roleMiddleware('admin'), GrpSubjController.addSubject)
router.delete('/admin/subjects/:id', roleMiddleware('admin'), GrpSubjController.deleteSubject)

router.get('/admin/grp-subj', roleMiddleware('admin'), GrpSubjController.getGroupsSubjects)

export default router