<template>
  <div class="auth">
    <h1 class="auth__title">
      {{ mode === 'login' ? 'АВТОРИЗАЦИЯ' : 'ПОДТВЕРЖДЕНИЕ' }}
    </h1>

    <form class="auth__form" @submit.prevent="handleSubmit">
      <div class="auth__form-inner">
        <template v-if="mode === 'login'">
          <div class="auth__label-container">
            <label class="auth__label" for="email">Почта</label>
          </div>
          <input
            class="auth__input input-style"
            type="text"
            id="email"
            v-model="email"
            placeholder="example@mail.ru"
            autocomplete="email"
          />

          <div class="auth__label-container">
            <label class="auth__label" for="password">Пароль</label>
          </div>
          <div class="auth__input-container">
            <input
              class="auth__input auth__input-pw input-style"
              :type="showPassword ? 'text' : 'password'"
              id="password"
              v-model="password"
              placeholder="password"
              autocomplete="current-password"
            />
            <button
              type="button"
              class="auth__password-toggle"
              @click="showPassword = !showPassword"
            >
              <EyeFillIcon v-if="showPassword" />
              <EyeOffIcon v-else />
            </button>
          </div>
        </template>

        <template v-else-if="mode === 'confirm'">
          <div class="auth__label-container">
            <label class="auth__label" for="code">Код подтверждения</label>
          </div>
          <input
            class="auth__input input-style"
            type="text"
            id="code"
            v-model="confirmationCode"
            placeholder="Введите код из почты"
            autocomplete="one-time-code"
          />
        </template>

        <button class="auth__button" type="submit" :disabled="submitDisabled">
          {{ submitButtonText }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import authStore from '@/stores/auth.store.js'
import EyeFillIcon from '@/assets/icons/EyeFillIcon.vue'
import EyeOffIcon from '@/assets/icons/EyeOffIcon.vue'

const router = useRouter()

const mode = ref('login')
const email = ref('')
const password = ref('')
const showPassword = ref(false)
const confirmationCode = ref('')

const submitDisabled = computed(() => {
  if (mode.value === 'login') return !email.value || !password.value
  if (mode.value === 'confirm') return !confirmationCode.value
  return true
})

const submitButtonText = computed(() => {
  if (mode.value === 'login') return 'Войти'
  if (mode.value === 'confirm') return 'Подтвердить'
  return 'Отправить'
})

const handleSubmit = async () => {
  if (mode.value === 'login') return login()
  if (mode.value === 'confirm') return confirmCode()
}

const login = async () => {
  try {
    const response = await authStore.login(email.value, password.value)
    if (response?.message === 'Требуется подтверждение нового устройства.') {
      mode.value = 'confirm'
    } else {
      redirectAfterLogin()
    }
  } catch (error) {
    alert('Ошибка входа: ' + extractErrorMessage(error))
  }
}

const extractErrorMessage = (e) => {
  if (Array.isArray(e?.response?.data?.message)) {
    return e.response.data.message.map((m) => `${m.path}: ${m.msg}`).join('\n')
  }
  return e?.response?.data?.message || e?.message || JSON.stringify(e) || 'Неизвестная ошибка'
}

const confirmCode = async () => {
  try {
    const response = await authStore.confirmNewDeviceCode(confirmationCode.value)
    if (response.sub) {
      redirectAfterLogin()
    } else {
      throw new Error('Ошибка подтверждения устройства.')
    }
  } catch (error) {
    alert('Ошибка подтверждения: ' + error.response.data.message || error)
  }
}

const redirectAfterLogin = () => {
  if (authStore.user.role === 'admin') {
    router.push('/admin')
  } else {
    router.push('/labs')
  }
}
</script>

<style scoped lang="scss">
@use '@/assets/styles/variables' as *;

.auth {
  position: absolute;
  top: 45%;
  left: 50%;
  transform: translate(-50%, -50%);

  &__title {
    display: flex;
    justify-content: center;
    align-self: center;
    font-size: 24px;
    font-weight: 600;
    margin-bottom: 12px;
  }

  &__form {
    width: 320px;
    height: 320px;
    border-radius: 28px;
    padding: 4px;
    box-shadow: 0 0 20px $color-gray-600;

    &-inner {
      display: flex;
      flex-direction: column;
      padding: 20px;
      border-radius: 24px;
      height: 310px;
      background: $color-gray-500;
    }
  }

  &__label-container {
    margin-top: 20px;
    margin-bottom: 5px;
  }

  &__label {
    color: $color-light;
    font-size: 20px;
  }

  &__input {
    width: 100%;
    font-size: 18px;

    &-pw {
      padding-right: 40px;
    }

    &-container {
      position: relative;
      display: flex;
      align-items: center;
    }
  }

  &__password-toggle {
    position: absolute;
    right: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: none;
    border: none;
    cursor: pointer;
    color: $color-gray-600;
    transition-duration: $td-02;

    &:hover {
      color: $color-dark;
    }

    svg {
      width: 20px;
      height: 20px;
    }
  }

  &__link {
    color: $color-light;
    font-size: 12px;
    margin: 10px 0;
    text-align: center;
    cursor: pointer;
  }

  &__button {
    margin-top: auto;
    padding: 10px;
    background: $color-light;
    color: $color-dark;
    border-radius: 8px;
    font-size: 18px;
    font-weight: 500;
    cursor: pointer;
    transition-duration: $td-02;

    &:disabled {
      cursor: not-allowed;
      opacity: 0.5;
    }

    &:hover:not(:disabled),
    &:focus:not(:disabled) {
      background-color: $color-gray-300;
    }
  }
}
</style>
