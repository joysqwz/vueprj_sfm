import $api from '@/helpers/http.helper'

export default class userProfileService {
  static async getUserProfile() {
    return $api.get(`/profile`)
  }
  static async updateSubjects(subjects) {
    return $api.put('/profile/lecturers/update-subjects', { subjects })
  }
  static async updateGroups(groups) {
    return $api.put('/profile/lecturers/update-groups', { groups })
  }
  static async changePassword({ currentPassword, newPassword }) {
    return $api.put('/profile/users/change-password', { currentPassword, newPassword })
  }
  static async changeEmail({ currentEmail, newEmail }) {
    return $api.put('profile/users/change-email', { currentEmail, newEmail })
  }
}
