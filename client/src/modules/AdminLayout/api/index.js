import $api from '@/helpers/http.helper'

export default class AdminService {
  static async getAccessAdmin() {
    return $api.get('/admin/access-admin')
  }
  static async getAllUsers() {
    return $api.get('/admin/users')
  }
  static async searchUsers(query) {
    return $api.get('/admin/users/search', { params: { query } })
  }
  static async updateUser(id, userData) {
    return $api.put(`/admin/users/${id}`, userData)
  }
  static async deleteUser(id) {
    return $api.delete(`/admin/users/${id}`)
  }
  static async quitSessions(id) {
    return $api.put(`/admin/users/quit/${id}`)
  }
  static async registrationAdmin(userData) {
    return $api.post('/admin/registration', userData)
  }

  static async getAllLabs() {
    return $api.get('/admin/labs')
  }
  static async searchLabs(query) {
    return $api.get('/admin/labs/search', { params: { query } })
  }

  static async getAllGroups() {
    return $api.get('/admin/groups')
  }
  static async addGroup(name) {
    return $api.post('/admin/groups', { name })
  }
  static async updateGroup(id, name) {
    return $api.put(`/admin/groups/${id}`, { name })
  }
  static async deleteGroup(id) {
    return $api.delete(`/admin/groups/${id}`)
  }

  static async getAllSubjects() {
    return $api.get('/admin/subjects')
  }
  static async addSubject(name) {
    return $api.post('/admin/subjects', { name })
  }
  static async updateSubject(id, name) {
    return $api.put(`/admin/subjects/${id}`, { name })
  }
  static async deleteSubject(id) {
    return $api.delete(`/admin/subjects/${id}`)
  }

  static async getGroupsSubjects() {
    return $api.get('/admin/grp-subj')
  }
}
