<template>
  <div class="labs-item block-style block-style--alt" @click="$emit('click')">
    <div class="labs-item__content">
      <h2 class="labs-item__title">{{ truncatedTitle }}</h2>
      <span class="labs-item__subject item-style item-style--subject text-nl">
        {{ props.labData.subject || 'Без предмета' }}</span
      >
    </div>
    <div class="labs-item__footer">
      <p v-if="props.userRole != 'student'" class="labs-item__group-wrapper">
        <span
          v-for="(group, index) in getGroupsArray(props.labData.lab_group)"
          :key="index"
          class="labs-item__group item-style item-style--group text-nl"
        >
          {{ group }}
        </span>
      </p>
      <span
        v-if="props.userRole === 'student'"
        class="labs-item__grade item-style item-style--grade"
        :class="badgeGradeClass"
      >
        <template v-if="props.labData.grade !== null && props.labData.grade !== undefined">
          {{ props.labData.grade }}
        </template>
        <template v-else> ? </template>
      </span>
      <p class="labs-item__data item-style item-style--data">{{ props.labData.created }}</p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  labData: {
    type: Object,
    required: true,
  },
  userRole: {
    type: String,
    required: true,
  },
})

defineEmits(['click', 'delete'])

const truncatedTitle = computed(() => {
  if (!props.labData || typeof props.labData.title !== 'string') {
    return 'Без названия'
  }
  const title = props.labData.title
  if (title.length <= 30) return title
  return title.slice(0, 30) + '...'
})

const getGroupsArray = (groups) => {
  if (Array.isArray(groups)) {
    return groups
  } else if (typeof groups === 'string') {
    return groups.split(',').map((g) => g.trim())
  } else {
    return []
  }
}

const badgeGradeClass = computed(() => {
  if (props.userRole !== 'student') return ''
  const grade = props.labData.grade
  if (grade === null || grade === undefined) return 'item-style--grade-null'
  if (grade === 0) return 'item-style--grade-0'
  if (grade === 1) return 'item-style--grade-1'
  if (grade === 2) return 'item-style--grade-2'
  return ''
})
</script>

<style scoped lang="scss">
@use '@/assets/styles/variables' as *;
@use '@/assets/styles/mixins' as *;

.labs-item {
  cursor: pointer;
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 250px;
  min-height: 180px;
  transition-duration: $td-02;
  box-shadow: 0 0 0 5px $color-gray-100;

  &:hover {
    box-shadow: 0 0 0 5px $color-gray-400;
  }

  &__title {
    display: flex;
    justify-content: center;
    text-align: center;
    flex-wrap: wrap;
    word-break: break-word;
    overflow-wrap: break-word;
    height: 52px;
    overflow: hidden;
  }

  &__content {
    display: flex;
    flex-direction: column;
    text-align: center;
    gap: 10px;
  }

  &__subject {
    display: flex;
    justify-content: center;
    align-items: center;
    text-overflow: ellipsis;
    min-height: 47px;
    width: 100%;
  }

  &__grade {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 32px;
    height: 32px;
    font-size: 18px;
    font-weight: 500;
  }

  &__group-wrapper {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    align-items: center;
    gap: 5px;
  }

  &__data {
    font-size: 14px;
  }

  &__footer {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: auto;
    gap: 10px;
  }
}
</style>
