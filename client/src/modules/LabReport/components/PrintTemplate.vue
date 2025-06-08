<template>
  <div ref="template" class="print-template">
    <h1 class="print-title">ОТЧЕТ ПО ЛАБОРАТОРНОЙ РАБОТЕ</h1>
    <p class="print-meta">{{ subject }}</p>
    <p class="print-meta">{{ group }}</p>
    <p class="print-date">{{ new Date().toLocaleDateString('ru-RU') }}</p>
    <table class="print-table">
      <thead>
        <tr>
          <th>№</th>
          <th>ФИО</th>
          <th>Сданные ЛБ</th>
          <th>Средняя оценка</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(student, index) in students" :key="student.user_id">
          <td>{{ index + 1 }}</td>
          <td>{{ getFio(student) }}</td>
          <td>{{ student.completed_labs || 0 }} / {{ student.total_labs || 0 }}</td>
          <td>{{ formatGrade(student.avg_grade) }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref } from 'vue'

defineProps({
  group: { type: String, default: '' },
  subject: { type: String, default: '' },
  students: { type: Array, default: () => [] },
})

const template = ref(null)
defineExpose({ template })

const getFio = (student) => {
  return [student.last_name, student.first_name, student.middle_name].filter(Boolean).join(' ')
}

const formatGrade = (grade) => {
  if (grade === null || grade === undefined) return '-'
  return grade.toFixed(1).replace('.0', '')
}
</script>

<style scoped>
.print-date {
  margin-top: 10px;
}

.print-title {
  text-align: center;
  font-size: 24px !important;
  margin: 0 !important;
  padding-bottom: 5px !important;
  font-weight: 500 !important;
}

.print-meta {
  text-align: center;
  margin: 0 !important;
  padding: 0 !important;
  font-weight: 400 !important;
  font-size: 20px !important;
  color: black !important;
}

.print-template {
  padding: 0 !important;
  margin: 0 !important;
  font-family: Arial, sans-serif;
}

.print-template h1 {
  text-align: center;
  font-size: 24px;
  margin-bottom: 20px;
}

.print-template p {
  text-align: center;
  font-size: 14px;
  color: #555;
  margin-bottom: 20px;
}

.print-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

.print-table th,
.print-table td {
  border: 1px solid #000;
  padding: 8px;
  text-align: center;
  font-size: 14px;
}

.print-table th {
  background-color: #f4f4f4;
  font-weight: bold;
}

.print-table tr:nth-child(even) {
  background-color: #f9f9f9;
}
</style>
