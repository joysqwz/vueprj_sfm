import $api from '@/helpers/http.helper'

export default class LabService {
  static async createLab(formData) {
    return $api.post('/labs', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  }
  static async getLecturerGS(id) {
    return $api.get(`/labs/lecturer/${id}/groups-subjects`)
  }
  static async getLabsByUser() {
    return $api.get(`/labs`)
  }
}
