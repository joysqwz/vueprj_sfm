<template>
  <div class="lab-list block-style block-style--alt">
    <div class="search-bar">
      <input
        v-model="searchQuery"
        type="text"
        id="lab-search"
        name="lab-search"
        class="input-style-alt"
        placeholder="Поиск"
      />
      <button class="btn-style" @click="loadAllLabs">Все ЛБ</button>
    </div>
    <table v-if="labs.length" class="lab-table">
      <thead>
        <tr>
          <th class="text-nl">№</th>
          <th class="text-nl">Название</th>
          <th class="text-nl">Группа</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(lab, index) in labs" :key="lab.id" @click="openLabDetails(lab.id)">
          <td>{{ index + 1 }}</td>
          <td class="text-nl">{{ lab.title }}</td>
          <td>
            {{
              Array.isArray(lab.group_names) ? lab.group_names.join(' ') : lab.group_names || '-'
            }}
          </td>
        </tr>
      </tbody>
    </table>
    <p v-else class="lab-list__empty">ЛБ не найдены</p>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import adminService from '../api'

const router = useRouter()
const labs = ref([])
const searchQuery = ref('')

let debounceTimeout = null

const performSearch = async (query) => {
  if (!query.trim()) {
    labs.value = []
    return
  }
  try {
    const response = await adminService.searchLabs(query)
    labs.value = response.data.labs || []
  } catch (error) {
    alert('Ошибка поиска ЛБ: ' + error.response.data.message || error)
  }
}

watch(searchQuery, (newQuery) => {
  clearTimeout(debounceTimeout)
  debounceTimeout = setTimeout(() => {
    performSearch(newQuery)
  }, 1000)
})

const loadAllLabs = async () => {
  try {
    const response = await adminService.getAllLabs()
    labs.value = response.data.labs || []
    searchQuery.value = ''
  } catch (error) {
    alert('Ошибка загрузки ЛБ: ' + error.response.data.message || error)
  }
}

const openLabDetails = (id) => {
  router.push(`/labs/${id}`)
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.lab-list {
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

.lab-table {
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

  tr:hover td {
    background: $color-gray-300;
  }

  tbody tr {
    cursor: pointer;
  }
}
</style>
