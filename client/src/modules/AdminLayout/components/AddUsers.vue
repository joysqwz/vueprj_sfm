<template>
  <div class="add-users block-style block-style--alt">
    <form @submit.prevent="addUser" class="user-form">
      <div class="form-group" v-for="field in fields" :key="field.id">
        <label class="form-group__label" :for="field.id">{{ field.label }}</label>
        <input
          v-if="field.type !== 'select'"
          class="form-group__input input-style-alt"
          :id="field.id"
          :name="field.model"
          v-model="user[field.model]"
          :type="field.type"
          :required="field.required"
          :autocomplete="getAutocomplete(field.model)"
          :disabled="isFieldDisabled(field.model)"
        />
        <select
          v-else
          class="form-group__select input-style-alt"
          :id="field.id"
          :name="field.model"
          v-model="user[field.model]"
          required
        >
          <option v-for="option in roleOptions" :key="option.value" :value="option.value">
            {{ option.label }}
          </option>
        </select>
      </div>

      <button type="submit" class="user-form__submit btn-style">
        <AddNewUser class="add-user-btn__icon" />
      </button>
    </form>

    <div class="file-upload">
      <label for="file-upload" class="file-upload__label">Загрузить список</label>
      <input
        id="file-upload"
        type="file"
        accept=".txt,.csv"
        @change="handleFileUpload"
        style="display: none"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import adminService from '../api'
import AddNewUser from '@/assets/icons/NewUserIcon.vue'

const user = ref({
  name: '',
  surname: '',
  patronymic: '',
  email: '',
  group: '',
  role: 'student',
})

const fields = [
  { id: 'role', label: 'Роль', model: 'role', type: 'select', required: true },
  { id: 'name', label: 'Имя', model: 'name', type: 'text', required: true },
  { id: 'surname', label: 'Фамилия', model: 'surname', type: 'text', required: true },
  { id: 'patronymic', label: 'Отчество', model: 'patronymic', type: 'text', required: true },
  { id: 'email', label: 'Почта', model: 'email', type: 'email', required: true },
  { id: 'group', label: 'Группа', model: 'group', type: 'text', required: true },
]

const roleOptions = [
  { label: 'Студент', value: 'student' },
  { label: 'Преподаватель', value: 'lecturer' },
  { label: 'Админ', value: 'admin' },
]

const addUser = async () => {
  try {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(user.value.email)) {
      alert('Некорректный email')
      return
    }
    const userData = {
      first_name: user.value.name,
      last_name: user.value.surname,
      middle_name: user.value.patronymic,
      email: user.value.email,
      group: user.value.role === 'student' ? user.value.group : null,
      role: user.value.role,
    }
    const response = await adminService.registrationAdmin({ users: [userData] })
    user.value = {
      name: '',
      surname: '',
      patronymic: '',
      email: '',
      group: '',
      role: 'student',
    }
    alert(`${response.data.message} ${userData.email}`)
  } catch (error) {
    alert('Ошибка добавления пользователя: ' + error.response.message || error)
  }
}

const handleFileUpload = async (event) => {
  const file = event.target.files[0]
  if (!file || (!file.name.endsWith('.txt') && !file.name.endsWith('.csv'))) {
    alert('Поддерживаются только .txt или .csv файлы')
    return
  }
  const reader = new FileReader()
  reader.onload = async (e) => {
    const text = e.target.result
    const users = parseUsersFromFile(text)
    if (users.length === 0) {
      alert('Файл пуст или содержит некорректные данные')
      return
    }
    try {
      const response = await adminService.registrationAdmin({ users })
      alert(response.data.message || 'Пользователи успешно добавлены')
    } catch (error) {
      alert('Ошибка при добавлении пользователей: ' + error.response.data.message || error)
    }
    event.target.value = ''
  }
  reader.onerror = () => {
    alert('Ошибка чтения файла')
  }
  reader.readAsText(file)
}

function parseUsersFromFile(text) {
  const lines = text.trim().split('\n')
  const users = []
  const validRoles = ['student', 'lecturer', 'admin']
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  const startIndex = lines[0].startsWith('name,surname') ? 1 : 0

  for (let i = startIndex; i < lines.length; i++) {
    const line = lines[i].trim()
    if (!line) continue

    const [name, surname, patronymic, email, group, role] = line.split(',').map((s) => s.trim())

    if (
      name &&
      surname &&
      patronymic &&
      emailRegex.test(email) &&
      group &&
      validRoles.includes(role)
    ) {
      users.push({
        first_name: name,
        last_name: surname,
        middle_name: patronymic,
        email: email,
        group: role === 'student' ? group : null,
        role: role,
      })
    } else {
      alert('Пропущена строка: ' + line)
    }
  }
  return users
}

function isFieldDisabled(model) {
  if (user.value.role === 'lecturer' && model === 'group') return true
  if (user.value.role === 'admin' && ['name', 'surname', 'patronymic', 'group'].includes(model))
    return true
  return false
}

function getAutocomplete(model) {
  switch (model) {
    case 'name':
      return 'off'
    case 'surname':
      return 'off'
    case 'patronymic':
      return 'off'
    case 'email':
      return 'off'
    case 'group':
      return 'off'
    default:
      return 'off'
  }
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.add-users {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  max-width: 500px;
  padding: 20px 50px;
  gap: 50px;
  position: relative;

  &-inner {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
  }
}

.user-form {
  display: flex;
  flex-direction: column;
  gap: 10px;

  &__submit {
    margin-top: 10px;
  }
}

.form-group {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 5px;

  &__input,
  &__select {
    width: 100%;
    max-width: 200px;

    &:disabled {
      cursor: not-allowed;
      background-color: $color-gray-400;
    }
  }

  &__select {
    background-color: $color-blue-100;
  }
}

.file-upload {
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
  width: 100%;
  height: 100px;
  background: $color-gray-300;
  border-radius: $br-8;
  transition-duration: $td-02;

  &:hover,
  &:focus {
    background-color: $color-gray-500;
  }

  &__label {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 100%;
    cursor: pointer;
  }
}

.add-user-btn__icon {
  width: 32px;
  height: 32px;
}
</style>
