import axios from 'axios'

export const API_URL = 'https://vueprj-sfmeied.ru//api'

const $api = axios.create({
  baseURL: API_URL,
  withCredentials: true,
})

$api.interceptors.response.use(
  (res) => res,
  async (error) => {
    const originalRequest = error.config
    if (error.response?.status === 401 && !originalRequest._isRetry) {
      originalRequest._isRetry = true
      try {
        await axios.get(`${API_URL}/auth/refresh`, { withCredentials: true })
        return $api.request(originalRequest)
      } catch (err) {
        if (originalRequest.url.includes('/check-auth')) {
          return Promise.reject(err)
        }
        window.location.href = '/login'
        return Promise.reject(err)
      }
    }
    return Promise.reject(error)
  },
)

export default $api