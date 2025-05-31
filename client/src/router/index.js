import { createRouter, createWebHistory } from 'vue-router'
import authStore from '@/stores/auth.store.js'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'root',
      component: { template: '<div />' },
      meta: { needAuth: true },
    },
    {
      path: '/labs',
      name: 'labs',
      component: () => import('@/pages/LabsPage.vue'),
      meta: { title: 'Лабораторные работы', needAuth: true },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/pages/AuthPage.vue'),
      meta: { title: 'Авторизация', needAuth: false },
    },
    {
      path: '/labs/:id',
      name: 'LabDetails',
      component: () => import('@/pages/LabDetailsPage.vue'),
      meta: { title: 'Информация о ЛБ', needAuth: true },
    },
    {
      path: '/admin',
      name: 'AdminPanel',
      component: () => import('@/pages/AdminPage.vue'),
      meta: { title: 'Админ-панель', needAuth: true, isAdmin: true },
    },
    {
      path: '/report',
      name: 'LabReport',
      component: () => import('@/pages/LabReportPage.vue'),
      meta: { title: 'Отчет по группам', needAuth: true, isLecturer: true },
    },
    {
      path: '/profile',
      name: 'UserProfile',
      component: () => import('@/pages/UserProfilePage.vue'),
      meta: { title: 'Профиль пользователя', needAuth: true },
    },
    {
      path: '/:catchAll(.*)',
      name: 'notFound',
      component: () => import('@/pages/NotFoundPage.vue'),
      meta: { title: '404', needAuth: false },
    },
  ],
})

router.beforeEach(async (to, from, next) => {
  if (authStore.isAuth.value === null && !authStore.isLoading.value && !authStore.justLoggedOut.value) {
    await authStore.checkAuth()
  }

  const isAuthenticated = authStore.isAuth.value
  const role = authStore.user?.role

  document.title = to.meta.title || ''

  if (to.meta.needAuth && !isAuthenticated) {
    authStore.justLoggedOut.value = false 
    return next({ name: 'login', query: { redirect: to.fullPath } }) 
  }

  if (to.name === 'login' && isAuthenticated) {
    authStore.justLoggedOut.value = false 
    return next({ name: role === 'admin' ? 'AdminPanel' : 'labs' })
  }

  if (to.name === 'root' && isAuthenticated) {
    authStore.justLoggedOut.value = false 
    return next({ name: role === 'admin' ? 'AdminPanel' : 'labs' })
  }

  if (to.meta.isAdmin && role !== 'admin') {
    authStore.justLoggedOut.value = false 
    return next({ name: 'labs' })
  }

  if (to.meta.isLecturer && role !== 'lecturer') {
    authStore.justLoggedOut.value = false
    return next({ name: 'labs' })
  }

  authStore.justLoggedOut.value = false
  next()
})

export default router
