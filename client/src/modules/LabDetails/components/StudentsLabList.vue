<template>
  <tr>
    <td>{{ studentData.number }}</td>
    <td>{{ studentData.fio || 'Не указано' }}</td>
    <td>{{ studentData.group_name || 'Без группы' }}</td>
    <td>
      <template v-if="!isCreator">
        <label :for="'grade-' + studentData.user_id" class="visually-hidden">Оценка</label>
        <span>{{
          !studentData.grade || studentData.grade === 'Не оценено' ? '-' : studentData.grade
        }}</span>
      </template>
      <template v-else>
        <select
          :id="'grade-' + studentData.user_id"
          :name="'grade-' + studentData.user_id"
          :value="studentData.grade"
          @change="$emit('update-grade', studentData, $event.target.value)"
          :style="gradeSelectStyle"
        >
          <option value="0">0</option>
          <option value="1">1</option>
          <option value="2">2</option>
        </select>
      </template>
    </td>
    <td>
      <ul v-if="studentData.report_files?.length" class="file-list">
        <li v-for="(file, index) in studentData.report_files" :key="index" class="file-item">
          <a :href="`/api/submissions/files/${file}`" target="_blank" rel="noopener">
            <img :src="getFileIcon(file)" alt="File icon" class="file-icon" />
          </a>
        </li>
      </ul>
      <span v-else>-</span>
    </td>
    <td>{{ studentData.submitted_at ? formatDate(studentData.submitted_at) : '-' }}</td>
  </tr>
</template>

<script setup>
import { computed } from 'vue'

const pdfIcon = '/icons/pdf-icon.png'
const wordIcon = '/icons/word-icon.png'
const defaultIcon = '/icons/file-icon.png'

const { studentData, isCreator } = defineProps({
  studentData: {
    type: Object,
    required: true,
  },
  isCreator: {
    type: Boolean,
  },
})

defineEmits(['update-grade'])

const getFileIcon = (fileName) => {
  if (!fileName || typeof fileName !== 'string') {
    return defaultIcon
  }
  const extension = fileName.split('.').pop().toLowerCase()
  switch (extension) {
    case 'pdf':
      return pdfIcon
    case 'doc':
    case 'docx':
      return wordIcon
    default:
      return defaultIcon
  }
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('ru-RU')
}

const getCssVar = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim()

const gradeSelectStyle = computed(() => {
  if (
    typeof studentData.grade === 'undefined' ||
    studentData.grade === null ||
    studentData.grade === '' ||
    studentData.grade === 'Не оценено'
  ) {
    return {}
  }
  if (studentData.grade == 0 || studentData.grade === '0') {
    return { backgroundColor: getCssVar('--color-red') }
  }
  if (studentData.grade == 1 || studentData.grade === '1') {
    return { backgroundColor: getCssVar('--color-yellow') }
  }
  if (studentData.grade == 2 || studentData.grade === '2') {
    return { backgroundColor: getCssVar('--color-green') }
  }
  return {}
})
</script>

<style scoped lang="scss">
@use '@/assets/styles/variables' as *;

.file {
  &-list {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: row;
    flex-wrap: wrap;
    gap: 8px;
    padding: 0;
    margin: 0;
  }

  &-item {
    display: flex;
    align-items: center;
    cursor: pointer;
  }

  &-icon {
    width: 24px;
    height: 24px;
  }
}

select {
  padding: 2px;
  font-size: 18px;
  width: 100%;
  text-align: center;
  border-radius: $br-8;
  background-color: $color-gray-200;
  border: 1px solid $color-gray-400;
  transition-duration: $td-02;
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
  cursor: pointer;

  &:hover,
  &:focus {
    background-color: $color-gray-300;
  }

  &::-ms-expand {
    display: none;
  }
}

td {
  padding: 5px;
  text-align: center;
  border-right: 1px solid $color-gray-400;
  border-bottom: 1px solid $color-gray-400;

  &:last-child {
    border-right: none;
  }
}

.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  white-space: nowrap;
  border: 0;
}

th:nth-child(1),
td:nth-child(1) {
  white-space: nowrap;
}

th:nth-child(2),
td:nth-child(2) {
  width: max-content;
}

th:nth-child(3),
td:nth-child(3) {
  white-space: nowrap;
}

th:nth-child(4),
td:nth-child(4) {
  width: 100px;
}

th:nth-child(5),
td:nth-child(5) {
  width: fit-content;
  max-width: 200px;
}

th:nth-child(6),
td:nth-child(6) {
  width: max-content;
}
</style>
