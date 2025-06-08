import '@/assets/styles/main.scss'

import { createApp } from 'vue'

import App from './App.vue'
import router from './router'

const app = createApp(App)

app.use(router).directive('focus', {
  mounted(el) {
    el.focus()
  },
})

app.mount('#app')
