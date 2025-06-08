<template>
  <MainLayout v-if="show">
    <div class="button-group">
      <button
        :class="['btn-style', { active: activeView === 'add-users' }]"
        @click="setView('add-users')"
      >
        Добавление пользователей
      </button>
      <button
        :class="['btn-style', { active: activeView === 'user-list' }]"
        @click="setView('user-list')"
      >
        Список пользователей
      </button>
      <button
        :class="['btn-style', { active: activeView === 'lab-list' }]"
        @click="setView('lab-list')"
      >
        Список ЛБ
      </button>
      <button
        :class="['btn-style', { active: activeView === 'groups-subjects' }]"
        @click="setView('groups-subjects')"
      >
        Группы и предметы
      </button>
    </div>
    <div class="admin-content">
      <component :is="currentComponent" />
    </div>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AddUsers from './components/AddUsers.vue'
import UserList from './components/UserList.vue'
import LabList from './components/LabList.vue'
import GroupsSubjects from './components/GroupsSubjects.vue'
import adminService from './api'
import MainLayout from '../MainLayout/MainLayout.vue'

const show = ref(false)
const activeView = ref('add-users')
const viewComponents = {
  'add-users': AddUsers,
  'user-list': UserList,
  'lab-list': LabList,
  'groups-subjects': GroupsSubjects,
}
const currentComponent = computed(() => viewComponents[activeView.value])
const setView = (view) => {
  activeView.value = view
}

onMounted(async () => {
  try {
    await adminService.getAccessAdmin()
    show.value = true
  } catch (error) {
    alert('Ошибка при получении доступа: ' + error.response.data.message || error)
  }
})
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.button-group {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  width: fit-content;
  margin: 0 auto;
  margin-bottom: 20px;
}

.admin-content {
  display: flex;
  justify-content: center;
  align-items: center;
  width: fit-content;
  margin: 0 auto;
}

.active {
  background-color: $color-gray-400;
}
</style>
