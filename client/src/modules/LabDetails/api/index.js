import $api from '@/helpers/http.helper'

export default class LabService {
  static async getLabDetails(id) {
    return $api.get(`/labs/${id}`)
  }
  static async updateStudentGrade(labId, userId, grade) {
    return $api.patch(`/labs/${labId}/student/${userId}/grade`, { grade })
  }
  static async deleteLab(id) {
    return $api.delete(`/labs/${id}`)
  }
  static async updateLab(formData) {
    return $api.put(`/labs/${formData.get('id')}`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  }
  static async uploadReport(formData) {
    return $api.post(`/labs/${formData.get('lab_id')}/submission`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  }
  static async getLecturerGS(id) {
    return $api.get(`/labs/lecturer/${id}/groups-subjects`)
  }
}
