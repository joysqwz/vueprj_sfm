<template>
  <MainLayout>
    <div class="report" v-if="!isLoading">
      <div v-if="subjects.length === 0" class="report__no-data">
        Нет предметов с лабораторными работами
      </div>
      <div v-else class="subjects">
        <ul class="subjects__list">
          <li
            v-for="subject in subjects"
            :key="subject.id"
            @click="selectSubject(subject)"
            :class="[
              'btn-style item-style text-nl',
              { 'item-style--group': selectedSubject?.id === subject.id },
            ]"
          >
            {{ subject.name }}
          </li>
        </ul>
      </div>

      <div v-if="selectedSubject && groups.length" class="groups">
        <ul class="groups__list">
          <li
            v-for="group in groups"
            :key="group.id"
            @click="selectGroup(group)"
            :class="[
              'groups__item',
              'btn-style item-style',
              { 'item-style--group': selectedGroup?.id === group.id },
            ]"
          >
            <span class="button__text">{{ group.name }}</span>
          </li>
        </ul>
      </div>

      <div v-if="selectedGroup && students.length" class="students">
        <h2 class="students__title">Студенты группы {{ selectedGroup.name }}</h2>
        <button @click="printReport" class="btn-style">
          <span class="button__text">Печать отчёта</span>
        </button>
        <div class="student-table-wrapper">
          <table class="student-table">
            <thead class="student-table__header">
              <tr>
                <th>№</th>
                <th>ФИО</th>
                <th>Сданные ЛБ</th>
                <th>Оценка</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(student, index) in students"
                :key="student.user_id"
                @click="openStudentModal(student)"
              >
                <td>{{ index + 1 }}</td>
                <td>{{ getFio(student) }}</td>
                <td>{{ student.completed_labs || 0 }} / {{ student.total_labs || 0 }}</td>
                <td>{{ formatGrade(student.avg_grade) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <StudentModal
        :show="showStudentModal"
        :student="selectedStudent"
        @close="closeStudentModal"
        @go-to-lab="goToLabDetails"
        class="modal"
        :class="{ 'modal--visible': showStudentModal }"
        target="_blank"
      />

      <PrintTemplate
        class="print-only"
        :group="selectedGroup?.name || ''"
        :subject="selectedSubject?.name || ''"
        :students="students"
        ref="printTemplate"
      />
    </div>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import labService from './api'
import authStore from '@/stores/auth.store.js'
import MainLayout from '../MainLayout/MainLayout.vue'
import StudentModal from './components/StudentModal.vue'
import PrintTemplate from './components/PrintTemplate.vue'

const router = useRouter()

const userId = computed(() => authStore.user.sub)

const subjects = ref([])
const groups = ref([])
const students = ref([])
const isLoading = ref(true)
const selectedSubject = ref(null)
const selectedGroup = ref(null)

const showStudentModal = ref(false)
const selectedStudent = ref({})
const printTemplate = ref(null)

onMounted(async () => {
  try {
    const response = await labService.getSubjectsByLecturer(userId.value)
    subjects.value = response.data.subjects || []
    isLoading.value = false
  } catch (error) {
    alert('Ошибка при загрузке предметов: ' + error.response.data.message || error)
  }
})

const selectSubject = async (subject) => {
  selectedSubject.value = subject
  selectedGroup.value = null
  students.value = []
  try {
    const response = await labService.getGroupsByCreator(userId.value, subject.id)
    groups.value = response.data.groups || []
  } catch (error) {
    alert('Ошибка при загрузке групп: ' + error.response.data.message || error)
  }
}

const selectGroup = async (group) => {
  selectedGroup.value = group
  try {
    const response = await labService.getStudentsByGroup(
      userId.value,
      group.id,
      selectedSubject.value.id,
    )
    const rawStudents = response.data.students || []

    rawStudents.sort((a, b) => {
      const fioA = getFio(a).toLowerCase()
      const fioB = getFio(b).toLowerCase()
      return fioA.localeCompare(fioB)
    })

    students.value = rawStudents
  } catch (error) {
    alert('Ошибка при загрузке студентов: ' + error.response.data.message || error)
  }
}

const getFio = (student) => {
  return [student.last_name, student.first_name, student.middle_name].filter(Boolean).join(' ')
}

const formatGrade = (grade) => {
  if (grade === null || grade === undefined) return '-'
  return Number.isInteger(grade) ? grade : grade.toFixed(1)
}

const openStudentModal = (student) => {
  selectedStudent.value = {
    fio: getFio(student),
    group: selectedGroup.value.name,
    subject: selectedSubject.value?.name || '',
    labs: student.labs || [],
  }
  showStudentModal.value = true
}

const closeStudentModal = () => {
  showStudentModal.value = false
  selectedStudent.value = {}
}

const goToLabDetails = (labId) => {
  const route = router.resolve({ name: 'LabDetails', params: { id: labId } })
  window.open(route.href, '_blank')
}

const printReport = () => {
  if (!selectedGroup.value || !students.value.length) {
    alert('Выберите группу с данными для печати')
    return
  }
  window.print()
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.subjects {
  display: flex;

  &__list {
    display: flex;
    justify-content: center;
    gap: 10px;
    list-style: none;
    padding: 0;
    margin: 0;
    flex-wrap: wrap;
  }
}

.report {
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  flex-direction: column;
  gap: 20px;
  padding: 10px 0;
  max-width: 1000px;
  margin: 0 auto;

  &__no-data {
    font-size: 24px;
  }
}

.groups {
  display: flex;
  flex-direction: column;

  &__list {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
    margin: 0;
    padding: 0;
    list-style: none;
  }

  &__item {
    font-size: 18px;
  }
}

.students {
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  gap: 20px;

  &__title {
    text-align: center;
    font-size: 24px;
  }
}

.student-table {
  margin: 0 auto;
  max-width: 1200px;
  border-spacing: 0;
  background-color: $color-light;
  border-radius: $br-8;
  font-size: 18px;
  border-left: 30px solid $color-gray-100;
  border-right: 30px solid $color-gray-100;
  border-bottom: 30px solid $color-gray-100;

  &-wrapper {
    width: 100%;
    overflow-x: auto;
  }

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

  th:nth-child(1),
  td:nth-child(1) {
    white-space: nowrap;
    min-width: 40px;
  }

  th:nth-child(4),
  td:nth-child(4) {
    white-space: nowrap;
  }
}

.print-only {
  display: none;
}
</style>
