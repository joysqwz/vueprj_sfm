import service from '../service/grp-subj-service.js'

class GrpSubjController {
	async getAllGroups(req, res, next) {
		try {
			const groups = await service.getAllGroups()
			res.json(groups)
		} catch (e) {
			next(e)
		}
	}
	async addGroup(req, res, next) {
		try {
			const { name } = req.body
			const group = await service.addGroup(name)
			res.json(group)
		} catch (e) {
			next(e)
		}
	}
	async updateGroup(req, res, next) {
		try {
			const { id } = req.params
			const { name } = req.body
			const group = await service.updateGroup(id, name)
			res.json(group)
		} catch (e) {
			next(e)
		}
	}
	async deleteGroup(req, res, next) {
		try {
			const { id } = req.params
			const group = await service.deleteGroup(id)
			res.json(group)
		} catch (e) {
			next(e)
		}
	}

	// ~~~~~~~~~

	async getAllSubjects(req, res, next) {
		try {
			const subjects = await service.getAllSubjects()
			res.json(subjects)
		} catch (e) {
			next(e)
		}
	}
	async addSubject(req, res, next) {
		try {
			const { name } = req.body
			const subject = await service.addSubject(name)
			res.json(subject)
		} catch (e) {
			next(e)
		}
	}
	async updateSubject(req, res, next) {
		try {
			const { id } = req.params
			const { name } = req.body
			const subject = await service.updateSubject(id, name)
			res.json(subject)
		} catch (e) {
			next(e)
		}
	}
	async deleteSubject(req, res, next) {
		try {
			const { id } = req.params
			const subject = await service.deleteSubject(id)
			res.json(subject)
		} catch (e) {
			next(e)
		}
	}

	// ~~~~~~~~~

	async getGroupsSubjects(req, res, next) {
		try {
			const grpSubj = await service.getGroupsSubjects()
			res.json(grpSubj)
		} catch (e) {
			next(e)
		}
	}
}
export default new GrpSubjController() 