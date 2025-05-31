<template>
  <div class="groups-subjects block-style block-style--alt" v-if="!isLoading">
    <div class="groups-subjects__section">
      <div
        class="groups-subjects__header btn-style"
        role="button"
        tabindex="0"
        @click="showGroupsModal = true"
        @keydown.enter="showGroupsModal = true"
      >
        <h2 class="groups-subjects__title">Группы</h2>
        <EditLabIcon class="groups-subjects__icon" />
      </div>
      <div class="groups-subjects__list">
        <div
          v-for="group in groups"
          :key="group.id"
          class="groups-subjects__item item-style item-style--group"
        >
          <template v-if="editing.id === group.id && editing.type === 0">
            <input
              v-model="editing.name"
              @keyup.enter="confirmUpdate(0)"
              @blur="confirmUpdate(0)"
              class="modal-input input-style"
              id="edit-group"
              v-focus
            />
          </template>
          <template v-else>
            <span class="groups-subjects__name">{{ group.name }}</span>
          </template>
          <button type="button" @click="toggleEditing(group, 0)" class="update-btn btn-style">
            <EditIcon />
          </button>
        </div>
      </div>
    </div>
    <div class="groups-subjects__section">
      <div
        class="groups-subjects__header btn-style"
        role="button"
        tabindex="0"
        @click="showSubjectsModal = true"
        @keydown.enter="showSubjectsModal = true"
      >
        <h2 class="groups-subjects__title">Предметы</h2>
        <EditLabIcon class="groups-subjects__icon" />
      </div>
      <div class="groups-subjects__list text-nl">
        <div
          v-for="subject in subjects"
          :key="subject.id"
          class="groups-subjects__item item-style item-style--subject"
        >
          <template v-if="editing.id === subject.id && editing.type === 1">
            <input
              v-model="editing.name"
              @keyup.enter="confirmUpdate(1)"
              @blur="confirmUpdate(1)"
              class="modal-input input-style"
              v-focus
              id="edit-subject"
            />
          </template>
          <template v-else>
            <span class="groups-subjects__name">{{ subject.name }}</span>
          </template>
          <button type="button" @click="toggleEditing(subject, 1)" class="update-btn btn-style">
            <EditIcon />
          </button>
        </div>
      </div>
    </div>

    <!-- Модальное окно для групп -->
    <transition name="modal-fade-overlay">
      <div v-if="showGroupsModal" class="modal-overlay">
        <div class="modal-content modal-narrow">
          <h3>Управление группами</h3>
          <input
            v-model="groupSearch"
            placeholder="Поиск группы..."
            class="modal-search input-style"
            id="search-group"
          />
          <form @submit.prevent="addItem(0)" class="modal-form">
            <input
              v-model="newGroup"
              placeholder="Новая группа"
              class="modal-input input-style"
              id="new-group"
            />
            <button type="submit" class="add-btn-modal btn-style btn-style--modal">
              <AddLabIcon />
            </button>
          </form>
          <div class="modal-list modal-list-row text-nl">
            <div
              v-for="group in filteredGroups"
              :key="group.id"
              class="group-item-modal item-style item-style--group"
            >
              <span class="group-name">{{ group.name }}</span>
              <button
                type="button"
                @click="removeItem(group.id, 0)"
                class="remove-btn btn-style"
              ></button>
            </div>
          </div>
          <button class="btn-style btn-style--modal" type="button" @click="showGroupsModal = false">
            Закрыть
          </button>
        </div>
      </div>
    </transition>

    <!-- Модальное окно для предметов -->
    <transition name="modal-fade-overlay">
      <div v-if="showSubjectsModal" class="modal-overlay">
        <div class="modal-content modal-narrow">
          <h3>Управление предметами</h3>
          <input
            v-model="subjectSearch"
            placeholder="Поиск предмета..."
            class="modal-search input-style"
            id="serch-subject"
          />
          <form @submit.prevent="addItem(1)" class="modal-form">
            <input
              v-model="newSubject"
              placeholder="Новый предмет"
              class="modal-input input-style"
              id="new-subject"
            />
            <button type="submit" class="add-btn-modal btn-style btn-style--modal">
              <AddLabIcon />
            </button>
          </form>
          <div class="modal-list modal-list-row text-nl">
            <div
              v-for="subject in filteredSubjects"
              :key="subject.id"
              class="subject-item-modal item-style item-style--subject"
            >
              <span class="subject-name">{{ subject.name }}</span>
              <button
                type="button"
                @click="removeItem(subject.id, 1)"
                class="remove-btn btn-style"
              ></button>
            </div>
          </div>
          <button
            class="btn-style btn-style--modal"
            type="button"
            @click="showSubjectsModal = false"
          >
            Закрыть
          </button>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import adminService from '../api'
import EditLabIcon from '@/assets/icons/EditLabIcon.vue'
import AddLabIcon from '@/assets/icons/AddLabIcon.vue'
import EditIcon from '@/assets/icons/EditIcon.vue'

const isLoading = ref(true)
const groups = ref([])
const subjects = ref([])
const newGroup = ref('')
const newSubject = ref('')
const groupSearch = ref('')
const subjectSearch = ref('')
const showGroupsModal = ref(false)
const showSubjectsModal = ref(false)

const editing = ref({ id: null, type: null, name: '' })

onMounted(async () => {
  await fetchGroupsSubjects()
  isLoading.value = false
})

async function fetchGroupsSubjects() {
  try {
    const response = await adminService.getGroupsSubjects()
    groups.value = response.data.groups || []
    subjects.value = response.data.subjects || []
  } catch (error) {
    alert('Ошибка загрузки: ' + error.response.data.message || error)
  }
}

function toggleEditing(item, type) {
  if (editing.value.id === item.id && editing.value.type === type) {
    editing.value = { id: null, type: null, name: '' }
  } else {
    editing.value = { id: item.id, type, name: item.name }
  }
}

async function confirmUpdate(type) {
  const trimmedName = editing.value.name.trim()

  if (
    !trimmedName ||
    trimmedName ===
      (type === 0
        ? groups.value.find((g) => g.id === editing.value.id).name
        : subjects.value.find((s) => s.id === editing.value.id).name)
  ) {
    editing.value = { id: null, type: null, name: '' }
    return
  }

  try {
    if (type === 0) {
      await adminService.updateGroup(editing.value.id, trimmedName)
      groups.value = groups.value
        .map((g) => (g.id === editing.value.id ? { ...g, name: trimmedName } : g))
        .sort((a, b) => a.name.localeCompare(b.name))
    } else {
      await adminService.updateSubject(editing.value.id, trimmedName)
      subjects.value = subjects.value
        .map((s) => (s.id === editing.value.id ? { ...s, name: trimmedName } : s))
        .sort((a, b) => a.name.localeCompare(b.name))
    }
  } catch (error) {
    alert('Ошибка обновления: ' + error.response.data.message || error)
  }

  editing.value = { id: null, type: null, name: '' }
}

async function addItem(type) {
  const value = type === 0 ? newGroup.value.trim() : newSubject.value.trim()
  if (!value) return

  const list = type === 0 ? groups.value : subjects.value
  if (list.some((item) => item.name === value)) return

  try {
    const response =
      type === 0 ? await adminService.addGroup(value) : await adminService.addSubject(value)

    if (type === 0) {
      groups.value = [...groups.value, response.data].sort((a, b) => a.name.localeCompare(b.name))
      newGroup.value = ''
    } else {
      subjects.value = [...subjects.value, response.data].sort((a, b) =>
        a.name.localeCompare(b.name),
      )
      newSubject.value = ''
    }
  } catch (error) {
    alert('Ошибка добавления: ' + error.response.data.message || error)
  }
}

async function removeItem(id, type) {
  try {
    if (type === 0) {
      await adminService.deleteGroup(id)
      groups.value = groups.value.filter((g) => g.id !== id)
    } else {
      await adminService.deleteSubject(id)
      subjects.value = subjects.value.filter((s) => s.id !== id)
    }
  } catch (error) {
    alert('Ошибка удаления: ' + error.response.data.message || error)
  }
}

const filteredGroups = computed(() => {
  if (!groupSearch.value) return groups.value
  return groups.value.filter((g) => g.name.toLowerCase().includes(groupSearch.value.toLowerCase()))
})

const filteredSubjects = computed(() => {
  if (!subjectSearch.value) return subjects.value
  return subjects.value.filter((s) =>
    s.name.toLowerCase().includes(subjectSearch.value.toLowerCase()),
  )
})
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.groups-subjects {
  display: flex;
  justify-content: center;
  flex-direction: column;
  gap: 20px;
  max-width: 1000px;

  &__section {
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 10px;
  }

  &__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 180px;
  }

  &__icon {
    width: 28px;
    height: 28px;
  }

  &__list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    font-size: 20px;
  }

  &__item {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
  }
}

.add-btn {
  width: 35px;
  height: 35px;
  padding: 2px !important;

  svg {
    width: 100%;
    height: 100%;
  }
}

.modal-overlay {
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
  gap: 15px;
}

.modal-narrow {
  min-width: 220px;
  max-width: 310px;
}

.modal-input {
  width: 200px;
}

.modal-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 180px;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: $color-gray-500 transparent;

  &::-webkit-scrollbar {
    width: 6px;
  }

  &::-webkit-scrollbar-track {
    background: transparent;
  }

  &::-webkit-scrollbar-thumb {
    background-color: $color-gray-500;
    border-radius: 3px;
  }
}

.modal-list-row {
  flex-direction: row;
  flex-wrap: wrap;
  gap: 8px;
}

.modal-search {
  width: 100%;
}

.group-item-modal {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 500;
  gap: 5px;
}

.subject-item-modal {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 5px;
}

.remove-btn {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  min-width: 30px;
  min-height: 30px;
  padding: 0;

  &:hover {
    color: $color-red-500;
  }

  &::before,
  &::after {
    content: '';
    position: absolute;
    width: 14px;
    height: 2px;
    background-color: currentColor;
    transition-duration: $td-02;
  }

  &::before {
    transform: rotate(45deg);
  }

  &::after {
    transform: rotate(-45deg);
  }
}

.update-btn {
  display: flex;
  justify-content: center;
  align-items: center;
  min-width: 30px;
  min-height: 30px;
  padding: 0;

  &:hover {
    color: $color-blue-500;
  }
}

.add-btn-modal {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 32px;
  height: 32px;
}

.modal-form {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 10px;

  input {
    width: 100%;
  }
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
</style>
