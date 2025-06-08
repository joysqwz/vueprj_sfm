import $api from '@/helpers/http.helper'

export default class AuthService {
  static async login(email, password) {
    return $api.post('/auth/login', { email, password })
  }

  static async logout() {
    return $api.post('/auth/logout')
  }
  static async confirmNewDeviceCode(code) {
    return $api.post('/auth/confirm-new-device', { code })
  }
}
