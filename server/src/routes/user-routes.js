import { Router } from 'express'
import userController from '../controllers/user-controller.js'
import { body } from 'express-validator'
import { roleMiddleware } from '../middlewares/role-middleware.js'
import { authMiddleware } from '../middlewares/auth-middleware.js'
import { groupMiddleware } from '../middlewares/group-middleware.js'

const router = Router()

// router.post(
// 	'/registration',
// 	body('email').isEmail(),
// 	body('password').isLength({ min: 6, max: 32 }),
// 	userController.registration
// )

router.get('/check-auth', userController.checkAuth)

router.post(
	'/auth/login',
	body('email').isEmail(),
	body('password').isLength({ min: 6, max: 32 }),
	userController.login
)
router.post(
	'/auth/confirm-new-device',
	body('code').isLength({ min: 6, max: 6 }).matches(/^[A-Z0-9]{6}$/),
	userController.confirmNewDeviceCode
)
router.post('/auth/logout', authMiddleware, userController.logout)
router.get('/auth/refresh', userController.refresh)

router.get('/profile', authMiddleware, userController.getProfile)
router.put('/profile/lecturers/update-subjects', roleMiddleware('lecturer'), userController.updateSubjects
)
router.put('/profile/lecturers/update-groups', roleMiddleware('lecturer'),
	userController.updateGroups
)
router.put('/profile/users/change-password', body('newPassword').isLength({ min: 6, max: 32 }), authMiddleware, userController.changePassword)
router.put('/profile/users/change-email', authMiddleware, userController.changeEmail)


router.get('/admin/access-admin', roleMiddleware(['admin']), userController.getAccessAdmin)
router.get('/admin/users', roleMiddleware(['admin']), userController.getUsers)
router.get('/admin/users/search', roleMiddleware(['admin']), userController.searchUsers)
router.put('/admin/users/:id', roleMiddleware(['admin']), userController.updateUser)
router.delete('/admin/users/:id', roleMiddleware(['admin']), userController.deleteUser)
router.put('/admin/users/quit/:id', roleMiddleware(['admin']), userController.quitSessions)
router.post('/admin/registration', roleMiddleware(['admin']), groupMiddleware, userController.registrationAdmin
)

export default router