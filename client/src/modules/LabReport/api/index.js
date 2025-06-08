import $api from '@/helpers/http.helper'

export default class LabService {
  static async getSubjectsByLecturer(lecturerId) {
    return $api.get(`/labs/lecturers/${lecturerId}/subjects`)
  }
  static async getGroupsByCreator(lecturerId, subjectId) {
    return $api.get(`/labs/lecturers/${lecturerId}/subjects/${subjectId}/groups`)
  }
  static async getStudentsByGroup(lecturerId, groupId, subjectId) {
    return $api.get(
      `/labs/lecturers/${lecturerId}/subjects/${subjectId}/groups/${groupId}/students`,
    )
  }
}
