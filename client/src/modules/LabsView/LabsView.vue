<template>
  <MainLayout>
    <div v-if="userRole === 'lecturer'" class="labs__buttons-container">
      <button type="button" @click="openModal" class="btn-style btn-style--img">
        <AddLabIcon />Создать ЛБ
      </button>
      <button type="button" @click="goToReport" class="btn-style btn-style--img">
        <ReportIcon />Отчёт по группам
      </button>
    </div>
    <div class="labs-list">
      <form-lab
        v-for="lab in labRows"
        :key="lab.id"
        :lab-data="lab"
        :user-role="userRole"
        @click="goToLabDetails(lab.id)"
        @delete="deleteLab(lab.id)"
      />
    </div>
    <div v-if="labRows.length === 0 && !isLoading">...</div>
    <AddLabModal
      :show="showModal"
      :user-role="userRole"
      :initial-data="newLab"
      :initial-files="selectedFiles"
      :lecturer-groups="lecturerGroups"
      :subjects="subjects"
      @close="closeModal"
      @save="createLab"
      @update="updateFormData"
      @update-lab="updateLabInList"
    />
  </MainLayout>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import FormLab from './components/FormLab.vue'
import AddLabModal from './components/AddLabModal.vue'
import labService from './api'
import authStore from '@/stores/auth.store.js'
import MainLayout from '../MainLayout/MainLayout.vue'
import { formatDate } from '@/helpers/formatDate.js'
import AddLabIcon from '@/assets/icons/AddLabIcon.vue'
import ReportIcon from '@/assets/icons/ReportIcon.vue'

const MAX_FILES = 10
const MAX_FILE_SIZE = 10 * 1024 * 1024

const isLoading = ref(true)
const userRole = computed(() => authStore.user.role)
const userId = computed(() => authStore.user.sub)
const labRows = reactive([])
const showModal = ref(false)
const newLab = reactive({
  title: '',
  group: '',
  description: '',
  subject_id: '',
})
const selectedFiles = ref([])
const lecturerGroups = ref([])
const subjects = ref([])

const router = useRouter()

const fetchLabs = async () => {
  try {
    isLoading.value = true
    const response = await labService.getLabsByUser()
    labRows.length = 0
    response?.data.labs.forEach((lab) => {
      lab.created = formatDate(lab.created)
      if (!lab.id) alert('ЛБ без ID: ' + lab)
      labRows.push(lab)
    })
  } catch (error) {
    alert('Ошибка при загрузке ЛБ: ' + error.response.data.message || error)
  } finally {
    isLoading.value = false
  }
}

onMounted(async () => {
  if (authStore.isAuth && authStore.user?.sub) {
    await fetchLabs()
  }
})

const goToLabDetails = (id) => {
  if (!id) {
    alert('ID ЛБ не определен')
    return
  }
  try {
    router.push({ name: 'LabDetails', params: { id } })
  } catch (error) {
    alert('Ошибка при переходе к информации ЛБ: ' + error.response.data.message || error)
  }
}

const deleteLab = async (id) => {
  if (!id) {
    alert('ID ЛБ не определен')
    return
  }
  try {
    await labService.deleteLab(id)
    const index = labRows.findIndex((lab) => lab.id === id)
    if (index !== -1) labRows.splice(index, 1)
  } catch (error) {
    alert('Ошибка при удалении ЛБ: ' + error.response.data.message || error)
  }
}

const updateFormData = (data) => {
  newLab.title = data.title
  newLab.group = data.group
  newLab.description = data.description
  selectedFiles.value = data.files
  newLab.subject_id = data.subject_id
}

const createLab = async (labData) => {
  try {
    if (labData.files.length > MAX_FILES) {
      alert(`Максимальное количество файлов: ${MAX_FILES}. Выбрано: ${labData.files.length}.`)
      return
    }
    for (const file of labData.files) {
      if (file.size > MAX_FILE_SIZE) {
        alert(
          `Файл "${file.name}" превышает максимальный размер ${MAX_FILE_SIZE / (1024 * 1024)} МБ.`,
        )
        return
      }
    }
    const formData = new FormData()
    formData.append('title', labData.title)
    const groupIds = Array.isArray(labData.group) ? labData.group : [labData.group]
    groupIds.forEach((g) => formData.append('group', g))
    formData.append('description', labData.description)
    formData.append('subject', labData.subject_id)
    labData.files.forEach((file) => formData.append('files', file))
    const response = await labService.createLab(formData)
    if (response?.data?.id && response?.data?.created) {
      const sortedGroupIds = groupIds.slice().sort((a, b) => {
        const aName = lecturerGroups.value.find((g) => g.id === a)?.name || ''
        const bName = lecturerGroups.value.find((g) => g.id === b)?.name || ''
        return aName.localeCompare(bName)
      })
      const groupNames = sortedGroupIds.map(
        (id) => lecturerGroups.value.find((g) => g.id === id)?.name,
      )
      labRows.unshift({
        id: response.data.id,
        title: labData.title,
        lab_group: groupNames.join(', '),
        description: labData.description,
        subject: subjects.value.find((sub) => sub.id === labData.subject_id)?.name,
        created: formatDate(response.data.created),
      })
      closeModal()
    } else {
      alert('Ошибка: сервер не вернул ID или дату создания новой лабораторной.')
    }
  } catch (error) {
    alert('Ошибка при создании ЛБ: ' + error.response.data.message || error)
  }
}

const goToReport = () => {
  router.push({ name: 'LabReport' })
}

const openModal = async () => {
  try {
    const res = await labService.getLecturerGS(userId.value)
    lecturerGroups.value = res.data.groups || []
    subjects.value = res.data.subjects || []
  } catch (error) {
    lecturerGroups.value = []
    subjects.value = []
    alert('Данные групп не были получены: ' + error.response.data.message || error)
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const resetForm = () => {
  newLab.title = ''
  newLab.group = ''
  newLab.description = ''
  newLab.subject_id = ''
  selectedFiles.value = []
}

const updateLabInList = (updatedLab) => {
  const index = labRows.findIndex((lab) => lab.id === updatedLab.id)
  if (index !== -1) {
    updatedLab.created = labRows[index].created || updatedLab.created
    labRows[index] = { ...labRows[index], ...updatedLab }
  }
}
</script>

<style scoped lang="scss">
@use '@/assets/styles/variables' as *;
@use '@/assets/styles/mixins' as *;

.labs-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.labs {
  &__buttons-container {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    padding-bottom: 20px;
  }

  &-list {
    display: flex;
    flex-wrap: wrap;
    padding-inline: 45px;
    gap: 20px;
  }
}
</style>
