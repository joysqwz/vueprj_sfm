import { v4 as uuidv4 } from 'uuid'

const COOKIE_KEY = 'unique_id'
const COOKIE_TTL_DAYS = 365

export const deviceIdManager = {
  async getOrSet() {
    let id = this.getFromCookie()
    if (id) {
      this.setCookie(id)
      return id
    }
    id = uuidv4()
    this.setCookie(id)
    return id
  },

  getFromCookie() {
    const match = document.cookie.match(new RegExp('(^|;\\s*)' + COOKIE_KEY + '=([^;]*)'))
    return match ? decodeURIComponent(match[2]) : null
  },

  setCookie(id) {
    const expires = new Date(Date.now() + COOKIE_TTL_DAYS * 86400e3).toUTCString()
    document.cookie = `${COOKIE_KEY}=${encodeURIComponent(id)}; expires=${expires}; path=/; SameSite=Lax; Secure`
  },
}
