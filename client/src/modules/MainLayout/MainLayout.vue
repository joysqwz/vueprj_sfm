<template>
  <div class="container">
    <div class="header block-style">
      <RouterLink :to="userRole !== 'admin' ? '/labs' : '/admin'" class="header__logo-link">
        <img :src="logo" class="header__logo" alt="Логотип" />
      </RouterLink>
      <h1
          :class="[
            'header__title',
            { 'header__title--alt': headerTitle === 'Панель администратора' },
          ]">
        {{ headerTitle }}
      </h1>
      <div class="header__buttons">
        <RouterLink v-if="userRole != 'admin'" to="/profile" class="header__profile-btn btn-style">
          <UserIcon class="header__profile-icon" />
        </RouterLink>
        <button @click="logout" class="header__logout-btn btn-style">
          <LogoutIcon class="header__logout-icon" />
        </button>
      </div>
    </div>
  </div>
  <div class="container--alt">
    <div class="content block-style">
      <div class="btn-wrapper btn-wrapper--left">
        <button v-if="showBackButton" @click="goBack" class="back-btn btn-style">
          <BackPageIcon class="back-btn__icon" />
        </button>
      </div>
      <slot></slot>
      <div class="btn-wrapper btn-wrapper--right">
        <button
                class="scrolled-btn scrolled-btn--top btn-style"
                v-if="isScrolled"
                @click="scrollToTop">
          <ToUpIcon class="scrolled-btn__icon" />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import logo from '@/assets/icons/logo.png'
import LogoutIcon from '@/assets/icons/LogoutIcon.vue'
import UserIcon from '@/assets/icons/UserIcon.vue'
import BackPageIcon from '@/assets/icons/BackPageIncon.vue'
import ToUpIcon from '@/assets/icons/ToUpIcon.vue'
import authStore from '@/stores/auth.store.js'

const router = useRouter()
const route = useRoute()
const isScrolled = ref(false)

const handleScroll = () => {
  isScrolled.value = window.scrollY > 130
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

const userRole = computed(() => authStore.user.role)

const showBackButton = computed(() => {
  return (route.path.startsWith('/labs/') && route.params.id) || route.path === '/report'
})

const goBack = () => {
  if (window.history.length > 1) {
    router.go(-1)
  } else {
    router.push(userRole.value !== 'admin' ? '/labs' : '/admin')
  }
}

const logout = async () => {
  try {
    await authStore.logout()
    router.push('/login')
  } catch (error) {
    alert('Ошибка при выходе: ' + error.response.data.message || error)
  }
}

const headerTitle = computed(() => {
  if (route.path === '/labs') {
    return 'Лабораторные работы'
  } else if (route.path.startsWith('/labs/') && route.params.id) {
    return `Лабораторные работы`
  } else if (route.path === '/admin') {
    return 'Панель администратора'
  } else if (route.path === '/report') {
    return 'Отчёт по группам'
  } else if (route.path === '/profile') {
    return 'Профиль пользователя'
  } else {
    return 'Главная'
  }
})

const scrollToTop = () => {
  window.scrollTo({
    top: 0,
    behavior: 'smooth',
  })
}
</script>

<style scoped lang="scss">
@use '@/assets/styles/variables' as *;
@use '@/assets/styles/mixins' as *;

.header {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 8px;
  min-height: 60px;
  max-height: 70px;
  width: 100%;
  overflow: hidden;

  &__logo {
    width: 100%;
    height: 100%;
    max-width: 40px;
    max-height: 40px;

    &-link {
      position: absolute;
      left: 10px;
      height: 40px;
    }
  }

  &__title {
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;

    &--alt {
      width: 70%;
      margin: 0;
    }
  }

  &__buttons {
    position: absolute;
    right: 10px;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  &__profile {
    &-btn {
      display: flex;
      justify-content: center;

      &.router-link-active {
        background: $color-gray-500;
      }
    }

    &-icon {
      width: 26px;
      height: 26px;
    }
  }

  &__logout {
    &-btn {
      display: flex;
      justify-content: center;
    }

    &-icon {
      width: 26px;
      height: 26px;
    }
  }
}

.btn-wrapper {
  position: absolute;
  top: 6px;
  height: 100%;
  z-index: 100;

  button {
    margin-bottom: 20px;
  }

  &--left {
    left: 6px;
  }

  &--right {
    right: 6px;
  }
}

.back-btn {
  position: sticky;
  top: 6px;
  display: flex;
  align-items: center;

  &__icon {
    width: 24px;
    height: 24px;
  }
}

.scrolled-btn {
  position: sticky;
  top: 90%;
  display: flex;
  align-items: center;
  scroll-behavior: smooth;

  &__icon {
    width: 24px;
    height: 24px;
  }
}

.content {
  position: relative;
  min-height: 200px;
}
</style>
