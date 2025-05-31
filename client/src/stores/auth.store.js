import { reactive, ref } from 'vue'
import authApi from '@/modules/Auth/api'
import $api from '@/helpers/http.helper.js'

export class AuthStore {
  constructor() {
    this.user = reactive({})
    this.isAuth = ref(null)
    this.isLoading = ref(false)
    this.justLoggedOut = ref(false)
  }

  setAuth(bool) {
    this.isAuth.value = bool
    this.justLoggedOut.value = false
  }

  setUser(userData) {
    Object.assign(this.user, userData)
  }

  setLoading(bool) {
    this.isLoading.value = bool
  }

  async login(email, password) {
    const response = await authApi.login(email, password)
    if (response.data.message === 'Требуется подтверждение нового устройства.') {
      return { message: response.data.message }
    }
    this.setAuth(true)
    this.setUser(response.data)
  }

  async logout() {
    try {
      await authApi.logout()
    } catch (error) {
      console.error('Logout error:', error)
    }
    this.setAuth(false)
    this.setUser({})
    this.isAuth.value = null
    this.justLoggedOut.value = true 
  }

  async checkAuth() {
    if (this.isAuth.value !== null || this.justLoggedOut.value) {
      return 
    }
    this.setLoading(true)
    try {
      const response = await $api.get('/check-auth')
      if (response.data.user) {
        this.setAuth(true)
        this.setUser(response.data.user)
      } else {
        this.setAuth(false)
        this.setUser({})
      }
    } catch {
      this.setAuth(false)
      this.setUser({})
    } finally {
      this.setLoading(false)
    }
  }

  async confirmNewDeviceCode(code) {
    const response = await authApi.confirmNewDeviceCode(code)
    this.setAuth(true)
    this.setUser(response.data)
    return response.data
  }
}

export default new AuthStore()
