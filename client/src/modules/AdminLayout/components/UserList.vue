<template>
  <div class="user-list block-style block-style--alt">
    <div class="search-bar">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Поиск"
        id="user-search"
        name="user-search"
        class="input-style-alt"
      />
      <button class="btn-style" @click="loadAllUsers">Показать всех</button>
    </div>
    <table v-if="users.length" class="user-table student-table">
      <thead>
        <tr>
          <th>№</th>
          <th>Фамилия</th>
          <th>Имя</th>
          <th>Отчество</th>
          <th>Группа</th>
          <th>Роль</th>
          <th>Почта</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(user, index) in users" :key="user.id">
          <td>{{ index + 1 }}</td>
          <td>{{ user.last_name || '-' }}</td>
          <td>{{ user.first_name || '-' }}</td>
          <td>{{ user.middle_name || '-' }}</td>
          <td>{{ user.group_name || '-' }}</td>
          <td>{{ user.role || '-' }}</td>
          <td>{{ user.email }}</td>
          <td>
            <button class="btn-style" @click="startEdit(user)">
              <EditIcon class="action-btn__icon" />
            </button>
            <button class="btn-style action-btn" @click="confirmDelete(user)">
              <DeleteIcon class="action-btn__icon" />
            </button>
            <button class="btn-style action-btn" @click="confirmQuitSessions(user)">
              <span class="black-circle action-btn__icon"></span>
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    <p v-else class="user-list__empty">Пользователи не найдены</p>
    <p class="user-list--warn">Требуется разрешение > 970px</p>

    <transition name="modal-fade-overlay">
      <div v-if="editingUser" class="modal">
        <div class="modal-content bordered">
          <form @submit.prevent="saveEdit">
            <div class="form-group" v-if="editingUser.role !== 'admin'">
              <label for="edit-last_name">Фамилия</label>
              <input
                v-model="editingUser.last_name"
                type="text"
                name="last_name"
                id="edit-last_name"
                class="input-style"
                autocomplete="off"
              />
            </div>
            <div class="form-group" v-if="editingUser.role !== 'admin'">
              <label for="edit-first_name">Имя</label>
              <input
                v-model="editingUser.first_name"
                type="text"
                name="first_name"
                id="edit-first_name"
                class="input-style"
                autocomplete="off"
              />
            </div>
            <div class="form-group" v-if="editingUser.role !== 'admin'">
              <label for="edit-middle_name">Отчество</label>
              <input
                v-model="editingUser.middle_name"
                type="text"
                name="middle_name"
                id="edit-middle_name"
                class="input-style"
                autocomplete="off"
              />
            </div>
            <div class="form-group">
              <label for="edit-email">Почта</label>
              <input
                v-model="editingUser.email"
                type="email"
                name="email"
                id="edit-email"
                class="input-style"
                autocomplete="off"
              />
            </div>
            <div class="form-group" v-if="editingUser.role === 'student'">
              <label for="edit-group_name">Группа</label>
              <input
                v-model="editingUser.group_name"
                type="text"
                name="group_name"
                id="edit-group_name"
                class="input-style"
                autocomplete="off"
              />
            </div>
            <div class="form-group">
              <span>Сбросить пароль</span>
              <div class="checkbox">
                <input
                  class="checkbox-input"
                  type="checkbox"
                  id="change-password"
                  v-model="changePassword"
                />
                <label class="checkbox-label" for="change-password"></label>
              </div>
            </div>
            <div class="modal-actions">
              <button type="submit" class="btn-style btn-style--modal">Сохранить</button>
              <button type="button" class="btn-style btn-style--modal" @click="cancelEdit">
                Отмена
              </button>
            </div>
          </form>
        </div>
      </div>
    </transition>

    <transition name="modal-fade-overlay">
      <div v-if="showDeleteConfirm" class="delete-confirm-modal__overlay">
        <div class="delete-confirm-modal__content">
          <h3>Подтверждение удаления</h3>
          <p class="text-nl">Вы точно хотите удалить пользователя {{ userEmailToDelete }}?</p>
          <div class="delete-confirm-modal__buttons">
            <button @click="deleteUser" class="btn-style btn-style--modal btn-style--big">
              Да
            </button>
            <button
              @click="showDeleteConfirm = false"
              class="btn-style btn-style--modal btn-style--big"
            >
              Нет
            </button>
          </div>
        </div>
      </div>
    </transition>

    <transition name="modal-fade-overlay">
      <div v-if="showQuitSessionsConfirm" class="delete-confirm-modal_wrapper">
        <div class="delete-confirm-modal__overlay">
          <div class="delete-confirm-modal__content">
            <h3>Подтверждение завершения сессий</h3>
            <p class="text-nl">
              Вы точно хотите завершить все сессии пользователя {{ userEmailToQuit }}?
            </p>
            <div class="delete-confirm-modal__buttons">
              <button @click="quitSessions" class="btn-style btn-style--modal btn-style--big">
                Да
              </button>
              <button
                @click="showQuitSessionsConfirm = false"
                class="btn-style btn-style--modal btn-style--big"
              >
                Нет
              </button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, watch, onUnmounted } from 'vue'
import adminService from '../api'
import EditIcon from '@/assets/icons/EditIcon.vue'
import DeleteIcon from '@/assets/icons/DeleteIcon.vue'

const users = ref([])
const searchQuery = ref('')
const editingUser = ref(null)
const initialUserState = ref(null)
const changePassword = ref(false)
const showDeleteConfirm = ref(false)
const userIdToDelete = ref(null)
const userEmailToDelete = ref('')
const showQuitSessionsConfirm = ref(false)
const userIdToQuit = ref(null)
const userEmailToQuit = ref('')
const debounceTimeout = ref(null)
const skipNextSearch = ref(false)

const confirmDelete = (user) => {
  userIdToDelete.value = user.id
  userEmailToDelete.value = user.email
  showDeleteConfirm.value = true
}

const confirmQuitSessions = (user) => {
  userIdToQuit.value = user.id
  userEmailToQuit.value = user.email
  showQuitSessionsConfirm.value = true
}

const quitSessions = async () => {
  const id = userIdToQuit.value
  if (!id) {
    alert('Ошибка: ID пользователя не найден')
    return
  }
  try {
    await adminService.quitSessions(id)
    showQuitSessionsConfirm.value = false
    userIdToQuit.value = null
    userEmailToQuit.value = ''
  } catch (error) {
    alert('Ошибка при завершении сессий: ' + error.response.data.message || error)
  }
}

let stopSearchWatch = watch(searchQuery, async (newQuery) => {
  if (skipNextSearch.value) {
    skipNextSearch.value = false
    return
  }

  clearTimeout(debounceTimeout.value)
  debounceTimeout.value = setTimeout(async () => {
    if (!newQuery.trim()) {
      users.value = []
      return
    }
    try {
      const response = await adminService.searchUsers(newQuery)
      users.value = response.data.users
    } catch (error) {
      alert('Ошибка поиска: ' + error.response.data.message || error)
    }
  }, 500)
})

onUnmounted(() => {
  stopSearchWatch()
  clearTimeout(debounceTimeout.value)
})

const loadAllUsers = async () => {
  try {
    const response = await adminService.getAllUsers()
    users.value = response.data.users
    skipNextSearch.value = true
    searchQuery.value = ''
    const input = document.getElementById('user-search')
    if (input) input.blur()
  } catch (error) {
    alert('Ошибка загрузки пользователей: ' + error.response.data.message || error)
  }
}

const startEdit = (user) => {
  const userData = {
    id: user.id,
    email: user.email ?? '',
    role: user.role ?? '',
    first_name: user.first_name ?? '',
    middle_name: user.middle_name ?? '',
    last_name: user.last_name ?? '',
    group_name: user.group_name ?? '',
    password: '',
  }
  editingUser.value = { ...userData }
  initialUserState.value = { ...userData }
  changePassword.value = false
}

const saveEdit = async () => {
  if (!editingUser.value.id) {
    alert('Ошибка: ID пользователя не найден')
    return
  }

  const updatedFields = {}
  Object.keys(editingUser.value).forEach((key) => {
    if (editingUser.value[key] !== initialUserState.value[key]) {
      updatedFields[key] = editingUser.value[key]
    }
  })
  delete updatedFields.password
  if (changePassword.value) {
    updatedFields.resetPassword = true
  }
  if (Object.keys(updatedFields).length === 0) {
    editingUser.value = null
    initialUserState.value = null
    changePassword.value = false
    return
  }
  try {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (updatedFields.email && !emailRegex.test(updatedFields.email)) {
      alert('Введите корректный адрес почты')
      return
    }
    await adminService.updateUser(editingUser.value.id, updatedFields)
    const index = users.value.findIndex((u) => u.id === editingUser.value.id)
    if (index !== -1) {
      users.value[index] = { ...users.value[index], ...updatedFields }
    }
    editingUser.value = null
    initialUserState.value = null
    changePassword.value = false
  } catch (error) {
    alert('Ошибка обновления: ' + error.response.data.message || error)
  }
}

const cancelEdit = () => {
  editingUser.value = null
  initialUserState.value = null
  changePassword.value = false
}

const deleteUser = async () => {
  const id = userIdToDelete.value
  if (!id) {
    alert('Ошибка: ID пользователя не найден')
    return
  }
  try {
    await adminService.deleteUser(id)
    users.value = users.value.filter((u) => u.id !== id)
    showDeleteConfirm.value = false
    userIdToDelete.value = null
    userEmailToDelete.value = ''
  } catch (error) {
    alert('Ошибка удаления: ' + error.response.data.message || error)
  }
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;
@use '@/assets/styles/_utilities.scss' as *;

.user-list {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  gap: 40px;
  max-width: 1280px;
  padding-block: 20px;
}

.search-bar {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 20px;

  input {
    padding: 5px;
    width: 100%;
    max-width: 240px;
  }
}

.user-table {
  margin: 0 auto;
  width: 100%;
  max-width: 1200px;
  border-spacing: 0;
  background-color: $color-light;
  border-radius: $br-8;
  font-size: 18px;
  border-left: 30px solid $color-gray-100;
  border-right: 30px solid $color-gray-100;
  border-bottom: 30px solid $color-gray-100;

  th,
  td {
    padding: 6px;
    text-align: center;
  }

  th {
    background: $color-gray-100;
    font-weight: 600;
    padding-block: 20px;
  }

  td {
    border-right: 1px solid $color-gray-400;
    border-bottom: 1px solid $color-gray-400;

    &:last-child {
      border-right: none;
    }
  }

  tr td {
    transition-duration: $td-02;
  }

  th:nth-child(1),
  td:nth-child(1) {
    white-space: nowrap;
  }
}

.action-btn {
  margin-left: 5px;

  svg {
    color: $color-red-500;
  }
}

.user-list__empty {
  text-align: center;
  font-size: 18px;
}

form {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: none;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 10px;
  overflow-y: auto;
}

.modal-content {
  background: $color-gray-400;
  box-shadow: $bs-out-dark;
  border-radius: $br-16;
  border: 6px solid $color-gray-500;
  padding: 20px;
  width: 300px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: center;
  margin-top: 18px;
}

.action-btn__icon {
  width: 22px;
  height: 22px;
  display: block;
}

.user-list--warn {
  text-align: center;
  display: none;
}

.modal-fade-overlay-enter-active,
.modal-fade-overlay-leave-active {
  transition: opacity $td-02;
}

.modal-fade-overlay-enter-from,
.modal-fade-overlay-leave-to {
  opacity: 0;
}

.modal-fade-overlay-enter-to,
.modal-fade-overlay-leave-from {
  opacity: 1;
}

.delete-confirm-modal__overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: none;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 10px;
}

.delete-confirm-modal__content {
  background: $color-gray-400;
  box-shadow: $bs-out-dark;
  border-radius: $br-16;
  border: 6px solid $color-gray-500;
  padding: 20px;
  width: 300px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  gap: 15px;
}

.delete-confirm-modal__buttons {
  display: flex;
  justify-content: center;
  gap: 10px;
}

.checkbox {
  display: flex;
  justify-content: center;
  align-items: center;
}

.checkbox-input {
  cursor: pointer;
  appearance: none;
  position: relative;
  width: 30px;
  height: 30px;
  background: $color-light;
  border-radius: $br-8;
  box-shadow: $bs-out-light;
  border: 1px solid transparent;
  transition: 0.5s;

  &:focus {
    border: 1px solid $color-gray-500;
  }
}

.checkbox-input::after {
  content: '\2714';
  position: absolute;
  top: 0;
  left: 4px;
  width: 0px;
  height: 0px;
  font-size: 26px;
  transition: 0.5s;
  overflow: hidden;
}

.checkbox-input:checked::after {
  width: 30px;
  height: 30px;
  transition: 0.3s;
}

.black-circle {
  width: 22px;
  height: 22px;
  border-radius: 50%;
  border: 4px solid $color-gray-600;
}
</style>
