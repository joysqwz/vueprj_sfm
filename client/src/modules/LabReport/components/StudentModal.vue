<template>
  <transition name="modal-fade-content">
    <div v-if="show" class="student-modal__overlay" :class="{ 'modal--visible': show }">
      <div class="student-modal__content">
        <h2 class="student-modal__title">{{ student.fio }}</h2>
        <p class="student-modal__group item-style item-style--subject" v-if="student.subject">
          {{ student.subject }}
        </p>
        <p class="student-modal__group item-style item-style--group">{{ student.group }}</p>

        <div v-if="student.labs.length">
          <h3>Список выполненных ЛБ</h3>
          <ul class="student-modal__lab-list">
            <li
                v-for="lab in student.labs"
                :key="lab.lab_id"
                @click="goToLab(lab.lab_id)"
                class="student-modal__lab-item"
                target="_blank">
              <span class="student-modal__lab-title">{{ lab.title }}</span>
              <span class="student-modal__lab-grade">Оценка: {{ formatGrade(lab.grade) }}</span>
            </li>
          </ul>
        </div>
        <div v-else class="student-modal__no-labs">Нет выполненных лабораторных работ</div>
        <div class="student-modal__buttons">
          <button @click="$emit('close')" class="student-modal__button btn-style btn-style--modal">
            Закрыть
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
defineProps({
  show: Boolean,
  student: {
    type: Object,
    default: () => ({ fio: '', group: '', labs: [] }),
  },
})

const emit = defineEmits(['close', 'go-to-lab'])

const formatGrade = (grade) => {
  if (grade == '0') return '0'
  if (!grade) return '-'
  const rounded = Math.round(grade)
  return rounded === 0 ? '0' : rounded.toString()
}

const goToLab = (labId) => {
  emit('go-to-lab', labId)
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.student-modal {
  &__overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
    overflow-y: auto;
    padding: 20px;
  }

  &__content {
    position: relative;
    display: flex;
    flex-direction: column;
    background: $color-gray-400;
    box-shadow: $bs-out-dark;
    border-radius: $br-16;
    border: 6px solid $color-gray-500;
    padding: 20px;
    width: 310px;
    gap: 15px;
    transition-duration: $td-02;
  }

  &__title {
    text-align: center;
    font-size: 20px;
    margin: 0;
  }

  &__group {
    font-size: 18px;
    margin: 0 auto;
  }

  &__lab-list {
    list-style: none;
    padding: 0;
    padding-top: 10px;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  &__lab-item {
    font-size: 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 5px;
    background-color: $color-gray-300;
    padding: 8px;
    border-radius: $br-8;
    transition-duration: $td-02;
    cursor: pointer;

    &:hover {
      box-shadow: $bs-in-light;
    }
  }

  &__lab-title {
    font-weight: 500;
  }

  &__lab-grade {
    background: $color-gray-200;
    padding: 2px 6px;
    border-radius: $br-8;
  }

  &__no-labs {
    text-align: center;
    color: $color-gray-500;
    font-style: italic;
    margin: 10px 0;
  }

  &__buttons {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-top: 10px;
  }

  &__button {
    font-size: 18px;
  }
}

.modal-fade-content-enter-active,
.modal-fade-content-leave-active {
  transition: $td-02;
}

.modal-fade-content-enter-from,
.modal-fade-content-leave-to {
  opacity: 0;
}

.modal-fade-content-enter-to,
.modal-fade-content-leave-from {
  opacity: 1;
  transform: none;
}
</style>
