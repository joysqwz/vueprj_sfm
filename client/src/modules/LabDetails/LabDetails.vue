<template>
  <MainLayout>
    <div v-if="!isLoading" class="lab-details">
      <div class="lab-details__header">
        <h2 class="lab-details__title text-nl">{{ labTitle }}</h2>
        <div v-if="lab.created_at" class="lab-details__date item-style item-style--data">
          {{ formatDate(lab.created_at) }}
        </div>
        <span
              v-if="lab.subject_name || lab.subject_id"
              class="lab-details__subject item-style item-style--subject">
          {{ lab.subject_name || 'Без предмета' }}
        </span>
        <div v-if="lab.groups && lab.groups.length && userRole !== 'student'" class="lab-groups">
          <span
                v-for="group in lab.groups"
                :key="group.name"
                class="lab-groups__item item-style item-style--group">
            {{ group.name }}
          </span>
        </div>
        <span
              v-if="userRole == 'student'"
              class="student-grade item-style item-style--grade"
              :class="gradeClass">{{ lab.grade == null ? '?' : lab.grade }}</span>
      </div>

      <div class="lab-details__section">
        <h3 class="lab-details__section-title">Описание</h3>
        <p class="lab-details__section-text text-nl">{{ labDescription || 'Не указано' }}</p>
      </div>

      <div v-if="lab.files && lab.files.length" class="lab-details__section">
        <h3 class="lab-details__section-title">Файлы</h3>
        <ul class="lab-details__section-files file-list text-nl">
          <li v-for="(file, index) in lab.files" :key="index" class="file-item">
            <a
               v-if="file"
               :href="`/api/labs/files/${file.file_name}`"
               target="_blank"
               rel="noopener"
               class="file-link item-style item-style--file">
              <img :src="getFileIcon(file.file_name)" alt="File icon" class="file-icon" />
              {{ formatFileName(file.file_name) }}
            </a>
          </li>
        </ul>
      </div>

      <div v-if="userRole === 'student'" class="lab-details__section">
        <div class="upload-report">
          <h3 class="lab-details__section-title">Ваш отчёт</h3>
          <label for="report-upload" class="upload-button">
            <UploadIcon />
          </label>
          <input
                 id="report-upload"
                 type="file"
                 multiple
                 accept=".pdf,.doc,.docx"
                 @change="handleReportUpload"
                 style="display: none" />
        </div>
        <ul v-if="studentReports.length" class="lab-details__section-files file-list">
          <li v-for="(file, index) in studentReports" :key="index" class="file-item">
            <a
               v-if="file"
               :href="`/api/submissions/files/${file}`"
               target="_blank"
               rel="noopener"
               class="file-link item-style item-style--file">
              <img :src="getFileIcon(file)" alt="File icon" class="file-icon" />
              {{ formatFileName(file) }}
            </a>
          </li>
        </ul>
        <p v-else class="lab-details__section-text text-nl">Отчёты не загружены</p>
      </div>

      <div v-if="userRole === 'lecturer'" class="lab-details__actions">
        <button @click="openEditModal" class="lab-details__actions-button btn-style">
          <EditIcon class="lab-details__actions-icon" />
        </button>
        <button @click="showDeleteConfirm = true" class="lab-details__actions-button btn-style">
          <DeleteIcon class="lab-details__actions-icon btn-style--c-red" />
        </button>
      </div>

      <template v-if="sortedStudents.length">
        <h3 class="lab-details__section-title text-nl">Список студентов</h3>
        <div class="lab-details__section lab-details__section--as-center">
          <div class="lab-details__section">
            <table class="students-table">
              <thead>
                <tr>
                  <th>№</th>
                  <th>ФИО</th>
                  <th>Группа</th>
                  <th>Оценка</th>
                  <th>Файлы</th>
                  <th>Дата</th>
                </tr>
              </thead>
              <tbody>
                <template v-for="(studentItem, index) in sortedStudents" :key="studentItem.user_id">
                  <tr
                      v-if="
                        index === 0 || studentItem.group_name !== sortedStudents[index - 1].group_name
                      "
                      class="group-divider">
                    <td colspan="6">{{ studentItem.group_name || ' Без группы' }}</td>
                  </tr>
                  <StudentsLabList
                                   :student-data="studentItem"
                                   :is-creator="isLecturer"
                                   @update-grade="updateGrade" />
                </template>
              </tbody>
            </table>
          </div>
        </div>
      </template>

      <EditLabModal :show="showEditModal" :initial-lab="lab" :initial-files="newFiles" @close="closeEditModal"
                    @save="saveChanges" />
    </div>
    <transition name="modal-fade-overlay">
      <div v-if="showDeleteConfirm" class="delete-confirm-modal__overlay">
        <div class="delete-confirm-modal__content">
          <h3>Подтверждение удаления</h3>
          <p>Вы точно хотите удалить лабораторную работу?</p>
          <div class="delete-confirm-modal__buttons">
            <button @click="deleteLab" class="btn-style btn-style--modal btn-style--big">Да</button>
            <button @click="showDeleteConfirm = false" class="btn-style btn-style--modal btn-style--big">
              Нет
            </button>
          </div>
        </div>
      </div>
    </transition>
  </MainLayout>
</template>

<script setup>
import { useRoute, useRouter } from 'vue-router'
import { ref, computed, onMounted } from 'vue'
import MainLayout from '../MainLayout/MainLayout.vue'
import labService from './api'
import StudentsLabList from './components/StudentsLabList.vue'
import EditLabModal from './components/EditLabModal.vue'
import authStore from '@/stores/auth.store.js'
import EditIcon from '@/assets/icons/EditIcon.vue'
import DeleteIcon from '@/assets/icons/DeleteIcon.vue'
import UploadIcon from '@/assets/icons/UploadIcon.vue'

const MAX_FILES = 10
const MAX_FILE_SIZE = 10 * 1024 * 1024
const ALLOWED_STUDENT_EXTENSIONS = ['pdf', 'doc', 'docx', 'png', 'jpeg', 'jpg', 'txt']

const pdfIcon = '/icons/pdf-icon.png'
const wordIcon = '/icons/word-icon.png'
const imageIcon = '/icons/image-icon.png'
const defaultIcon = '/icons/file-icon.png'

const route = useRoute()
const router = useRouter()
const lab = ref({})
const student = ref([])
const isLoading = ref(true)
const showEditModal = ref(false)
const newFiles = ref([])
const isLecturer = ref(authStore.user.role === 'lecturer')
const userRole = authStore.user.role
const studentReports = ref([])
const showDeleteConfirm = ref(false)

const labTitle = computed(() => lab.value.title || 'Не указано')
const labDescription = computed(() => lab.value.description || 'Не указано')

const sortedStudents = computed(() => {
  if (!student.value.length || !lab.value.groups) return []

  const students = [...student.value]
  const groupOrder = lab.value.groups.map((group) => group.name).sort((a, b) => a.localeCompare(b))

  const sorted = students.sort((a, b) => {
    const groupA = a.group_name || ''
    const groupB = b.group_name || ''
    const indexA = groupOrder.indexOf(groupA)
    const indexB = groupOrder.indexOf(groupB)
    const orderA = indexA === -1 ? Infinity : indexA
    const orderB = indexB === -1 ? Infinity : indexB

    if (orderA === orderB) {
      const [surnameA = ''] = a.fio.split(' ')
      const [surnameB = ''] = b.fio.split(' ')
      return surnameA.localeCompare(surnameB, 'ru')
    }
    return orderA - orderB
  })

  let currentGroup = null
  let groupNumber = 0

  return sorted.map((student) => {
    if (student.group_name !== currentGroup) {
      currentGroup = student.group_name
      groupNumber = 1
    }
    return { ...student, number: groupNumber++ }
  })
})

onMounted(async () => {
  const labId = route.params.id
  if (labId) {
    await fetchLabDetails(labId)
  }
  isLoading.value = false
})

const fetchLabDetails = async (id) => {
  try {
    const response = await labService.getLabDetails(id)
    lab.value = {
      ...response.data.lab,
      files: Array.isArray(response.data.lab.files)
        ? response.data.lab.files.filter(
          (file) => file && typeof file === 'object' && file.file_name,
        )
        : [],
    }
    student.value = response.data.students || []

    if (userRole === 'student') {
      const reports = response.data.student_submission?.file_names || []
      studentReports.value = Array.isArray(reports) ? reports : []
    } else {
      student.value = response.data.students.map((student) => ({
        ...student,
        file_name: student.file_names ? [student.file_names] : [],
      }))
    }
  } catch (error) {
    alert('Ошибка при загрузке деталей ЛБ: ' + error.response.data.message || error)
    router.push('/labs')
  }
}

const gradeClass = computed(() => {
  const grade = lab.value.grade
  if (grade === null || grade === undefined) return 'item-style--grade-null'
  if (grade === 0) return 'item-style--grade-0'
  if (grade === 1) return 'item-style--grade-1'
  if (grade === 2) return 'item-style--grade-2'
  return ''
})

const updateGrade = async (studentItem, newGrade) => {
  try {
    const labId = route.params.id
    if (!labId || !studentItem.user_id) throw new Error('Отсутствует labId или user_id')
    await labService.updateStudentGrade(labId, studentItem.user_id, newGrade)
    const studentIndex = student.value.findIndex((s) => s.user_id === studentItem.user_id)
    if (studentIndex !== -1) {
      student.value[studentIndex].grade = newGrade
      student.value = [...student.value]
    }
  } catch (error) {
    alert('Ошибка при обновлении оценки: ' + error.response.data.message || error)
  }
}

const deleteLab = async () => {
  try {
    const labId = route.params.id
    await labService.deleteLab(labId)
    showDeleteConfirm.value = false
    router.push('/labs')
  } catch (error) {
    alert('Ошибка при удалении ЛБ: ' + error.response.data.message || error)
  }
}

const openEditModal = () => {
  showEditModal.value = true
}

const closeEditModal = () => {
  showEditModal.value = false
  newFiles.value = []
}

const saveChanges = async (changedFields, newFilesToUpload) => {
  try {
    const labId = route.params.id
    if (!labId) throw new Error('ID лабораторной работы не определён')

    const formData = new FormData()
    formData.append('id', labId)

    Object.entries(changedFields).forEach(([key, value]) => {
      if (key === 'existingFiles') {
        value.forEach((file, index) => formData.append(`existingFiles[${index}]`, file))
      } else {
        formData.append(key, value)
      }
    })

    newFilesToUpload.forEach((file) => formData.append('files', file))

    const response = await labService.updateLab(formData)
    if (response.data.message === 'ЛБ успешно обновлена') {
      lab.value = {
        ...lab.value,
        title: changedFields.title || lab.value.title,
        description: changedFields.description || lab.value.description,
        files: response.data.files || [],
      }
      newFiles.value = []
      showEditModal.value = false
    }
  } catch (error) {
    alert('Не удалось сохранить изменения: ' + error.response.data.message || error)
  }
}

const handleReportUpload = async (event) => {
  try {
    const files = Array.from(event.target.files)
    if (!files.length) {
      alert('Выберите хотя бы один файл для загрузки')
      return
    }
    if (files.length + studentReports.value.length > MAX_FILES) {
      alert(
        `Максимальное количество файлов: ${MAX_FILES}. Выбрано: ${files.length + studentReports.value.length}.`,
      )
      return
    }

    const existingFileNames = studentReports.value
    const validFiles = []
    for (const file of files) {
      if (file.size > MAX_FILE_SIZE) {
        alert(
          `Файл "${file.name}" превышает максимальный размер ${MAX_FILE_SIZE / (1024 * 1024)} МБ.`,
        )
        return
      }
      const extension = getFileExtension(file.name)
      if (!ALLOWED_STUDENT_EXTENSIONS.includes(extension)) {
        alert(
          `Файл "${file.name}" имеет недопустимый формат. Допустимые форматы: ${ALLOWED_STUDENT_EXTENSIONS.join(', ')}.`,
        )
        return
      }
      if (existingFileNames.includes(file.name)) {
        alert(`Файл "${file.name}" уже добавлен.`)
        continue
      }
      validFiles.push(file)
    }

    if (!validFiles.length) return

    const labId = route.params.id
    const formData = new FormData()
    formData.append('lab_id', labId)
    validFiles.forEach((file) => formData.append('submissions', file))

    const response = await labService.uploadReport(formData)
    const newReports = response.data.submission_files
    if (newReports && Array.isArray(newReports)) {
      studentReports.value = [...studentReports.value, ...newReports]
      alert('Отчёт успешно загружен')
    }
  } catch (error) {
    alert('Ошибка при загрузке отчётов: ' + error.response.data.message || error)
  }
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('ru-RU')
}

const getFileIcon = (fileName) => {
  if (!fileName || typeof fileName !== 'string') return defaultIcon
  const extension = getFileExtension(fileName)
  switch (extension) {
    case 'pdf':
      return pdfIcon
    case 'doc':
    case 'docx':
      return wordIcon
    case 'png':
    case 'jpeg':
    case 'jpg':
      return imageIcon
    default:
      return defaultIcon
  }
}

const getFileExtension = (filename) => {
  if (!filename || typeof filename !== 'string') return ''
  return filename.split('.').pop().toLowerCase()
}

const formatFileName = (fileName) => {
  if (!fileName || typeof fileName !== 'string') return 'Неизвестный файл'
  let name = fileName.replace(/\.[^/.]+$/, '')
  name = name.replace(/-\d+$/, '')
  return name
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.lab-details {
  width: 100%;
  padding: 10px 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  gap: 30px;

  &__header {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    gap: 5px;
    width: 90%;
  }

  &__title {
    text-align: center;
    font-size: 32px;
  }

  &__date {
    font-size: 16px;
    margin-bottom: 15px;
  }

  &__subject {
    font-size: 24px;
    text-align: center;
    margin-bottom: 5px;
  }

  .lab-groups {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 10px;

    &__item {
      font-size: 20px;
    }
  }

  &__section {
    display: flex;
    align-items: start;
    justify-content: center;
    align-self: flex-start;
    flex-wrap: wrap;
    flex-direction: column;
    gap: 5px;

    &--as-center {
      overflow-x: auto;
      max-width: 100%;
      align-self: inherit;
      align-items: center;
      gap: 20px;
    }

    &-title {
      align-items: center;
      font-size: 24px;
      font-weight: 600;
    }

    &-text {
      white-space: pre-wrap;
      font-size: 18px;
      padding: 10px;
      background-color: $color-gray-100;
      border-radius: $br-8;
    }

    &-files {
      padding: 0;
    }
  }

  &__actions {
    position: absolute;
    top: 5px;
    right: 5px;
    display: flex;
    flex-direction: column;
    gap: 10px;

    &-button {
      display: flex;
      align-items: center;
      justify-content: center;
    }

    &-icon {
      width: 24px;
      height: 24px;
    }
  }
}

.report-section {
  margin: 28px 0 18px 0;
  border-radius: 10px;
  padding: 0;
  box-shadow: none;
  background: none;
}

.file {
  &-list {
    list-style: none;
    margin: 0;
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }

  &-link {
    display: flex;
    justify-content: center;
    align-items: center;
    text-decoration: none;
    gap: 10px;
    font-size: 18px;
    transition-duration: $td-02;
    color: $color-dark;

    &:hover {
      background-color: $color-gray-400 !important;
    }
  }

  &-icon {
    width: 24px;
    height: 24px;
  }
}

.students-table {
  width: auto;
  max-width: 1280px;
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
    font-size: 18px;
    white-space: nowrap;
  }

  th {
    background: $color-gray-100;
    color: $color-dark;
    font-weight: 700;
    padding-block: 20px;
  }
}

tr.group-divider {
  font-weight: 700;
  color: $color-dark;
  background: $color-gray-200;
}

.upload-report {
  display: flex;
  justify-content: start;
  align-items: center;
  gap: 20px;
  margin-bottom: 5px;
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

.btn-style--big {
  font-size: 18px;
  padding: 5px;
  width: 80px;
  height: 40px;
}

.upload-button {
  width: 80px;
  height: 30px;
  cursor: pointer;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2px 2px;
  background-color: $color-gray-200;
  border: $border;
  border-radius: 4px;
  transition-duration: $td-02;

  svg {
    width: 100%;
    height: 100%;
  }

  &:hover {
    background-color: $color-gray-400;
  }
}

.student-grade {
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 20px;
  width: 36px;
  height: 36px;
}
</style>
