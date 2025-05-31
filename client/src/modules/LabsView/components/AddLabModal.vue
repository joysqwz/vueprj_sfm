<template>
  <transition name="modal-fade-overlay">
    <div v-if="show" class="add-lab-modal__overlay">
      <div class="add-lab-modal__content">
        <h3 class="add-lab-modal__title">Создание ЛБ</h3>

        <div class="add-lab-modal__field">
          <label for="lab-title" class="add-lab-modal__label">Заголовок</label>
          <input
                 v-model="localTitle"
                 @input="update"
                 id="lab-title"
                 class="add-lab-modal__input input-style" />
        </div>

        <div class="add-lab-modal__field">
          <button
                  type="button"
                  class="add-lab-modal__label add-lab-modal__label--btn add-lab-modal__subject-label"
                  @click="showSubjectsModal = true">
            Предмет
            <OpenIcon />
          </button>
          <div class="add-lab-modal__subject-selected">
            <span v-if="localSubject" class="item-style item-style--subject">
              {{ subjectName(localSubject) }}
            </span>
            <span v-else class="add-lab-modal__subject-placeholder">Не выбран</span>
          </div>
        </div>

        <div class="add-lab-modal__field">
          <button
                  type="button"
                  class="add-lab-modal__label add-lab-modal__label--btn add-lab-modal__groups-label"
                  @click="showGroupsModal = true">
            Группы
            <OpenIcon />
          </button>
          <div class="add-lab-modal__groups-selected">
            <span
                  v-for="groupId in sortedLocalGroup"
                  :key="groupId"
                  class="add-lab-modal__group-badge item-style item-style--group">
              {{ groupName(groupId) }}
            </span>
          </div>
        </div>

        <div class="add-lab-modal__field">
          <label for="lab-description" class="add-lab-modal__label">Описание</label>
          <textarea
                    v-model="localDescription"
                    rows="4"
                    @input="update"
                    id="lab-description"
                    class="add-lab-modal__textarea textarea-style"></textarea>
        </div>

        <div class="add-lab-modal__field">
          <label
                 for="file-upload"
                 class="add-lab-modal__file-label bordered bordered--btn bordered--color-gray">
            Выбрать файлы
            <input
                   id="file-upload"
                   type="file"
                   multiple
                   @change="handleFileUpload"
                   class="add-lab-modal__file-input" />
          </label>
        </div>

        <div v-if="localFiles.length" class="add-lab-modal__files">
          <div v-for="(file, index) in localFiles" :key="index" class="add-lab-modal__file">
            <span class="add-lab-modal__filename">{{ file.name }}</span>
            <button type="button" @click="removeFile(index)" class="add-lab-modal__remove-btn">
              <DeleteIcon />
            </button>
          </div>
        </div>

        <div class="add-lab-modal__buttons">
          <button @click="save" class="add-lab-modal__button btn-style btn-style--modal">
            Сохранить
          </button>
          <button @click="emit('close')" class="add-lab-modal__button btn-style btn-style--modal">
            Отмена
          </button>
        </div>
      </div>

      <transition name="modal-fade-content">
        <div v-if="showGroupsModal" class="groups-modal__overlay">
          <div class="groups-modal__content">
            <div class="groups-badges-list">
              <span
                    v-for="group in sortedLecturerGroups"
                    :key="group.id"
                    class="group-badge-select item-style"
                    :class="{ 'item-style--group': localGroup.includes(group.id) }"
                    @click="toggleGroup(group.id)">
                {{ group.name }}
              </span>
            </div>
            <div class="groups-modal__buttons">
              <button @click="showGroupsModal = false" class="groups-modal__button btn-style">
                Закрыть
              </button>
            </div>
          </div>
        </div>
      </transition>

      <transition name="modal-fade-content">
        <div v-if="showSubjectsModal" class="groups-modal__overlay">
          <div class="groups-modal__content">
            <div class="groups-badges-list">
              <span
                    v-for="subject in props.subjects"
                    :key="subject.id"
                    class="group-badge-select item-style"
                    :class="{ 'item-style--subject': localSubject === subject.id }"
                    @click="selectSubject(subject.id)">
                {{ subject.name }}
              </span>
            </div>
            <div class="groups-modal__buttons">
              <button @click="showSubjectsModal = false" class="groups-modal__button btn-style">
                Закрыть
              </button>
            </div>
          </div>
        </div>
      </transition>
    </div>
  </transition>
</template>

<script setup>
import { ref, watch, computed, onMounted, onUnmounted } from 'vue'
import OpenIcon from '@/assets/icons/OpenIcon.vue'
import DeleteIcon from '@/assets/icons/DeleteIcon.vue'

const MAX_FILES = 10
const MAX_FILE_SIZE = 10 * 1024 * 1024

const props = defineProps({
  show: Boolean,
  userRole: String,
  initialData: Object,
  initialFiles: Array,
  lecturerGroups: Array,
  subjects: Array,
})

const emit = defineEmits(['close', 'save', 'update'])

const sortedLecturerGroups = computed(() => {
  return [...props.lecturerGroups].sort((a, b) => a.name.localeCompare(b.name))
})

const localTitle = ref(props.initialData?.title || '')
const localGroup = ref(
  Array.isArray(props.initialData?.group)
    ? props.initialData.group
    : props.initialData?.group
      ? [props.initialData.group]
      : [],
)
const localDescription = ref(props.initialData?.description || '')
const localFiles = ref([...(props.initialFiles || [])])
const localSubject = ref(props.initialData?.subject_id || '')

const showGroupsModal = ref(false)
const showSubjectsModal = ref(false)

const blockScroll = () => (document.body.style.overflow = 'hidden')
const unblockScroll = () => (document.body.style.overflow = '')

watch(
  () => props.show,
  (newVal) => (newVal ? blockScroll() : unblockScroll()),
)
onMounted(() => props.show && blockScroll())
onUnmounted(unblockScroll)

const update = () => {
  emit('update', {
    title: localTitle.value,
    group: localGroup.value,
    description: localDescription.value,
    files: localFiles.value,
    subject_id: localSubject.value,
  })
}

const handleFileUpload = (e) => {
  const newFiles = Array.from(e.target.files)
  const totalFiles = localFiles.value.length + newFiles.length

  if (totalFiles > MAX_FILES) {
    alert(`Максимальное количество файлов: ${MAX_FILES}. Выбрано: ${totalFiles}.`)
    return
  }

  for (const file of newFiles) {
    if (file.size > MAX_FILE_SIZE) {
      alert(
        `Файл "${file.name}" превышает максимальный размер ${MAX_FILE_SIZE / (1024 * 1024)} МБ.`,
      )
      return
    }
  }

  localFiles.value = [...localFiles.value, ...newFiles]
  update()
}

const sortedLocalGroup = computed(() => {
  return localGroup.value.slice().sort((a, b) => {
    const aName = groupName(a)
    const bName = groupName(b)
    return aName.localeCompare(bName)
  })
})

const removeFile = (index) => {
  localFiles.value.splice(index, 1)
  update()
}

const toggleGroup = (groupId) => {
  const index = localGroup.value.indexOf(groupId)
  if (index !== -1) {
    localGroup.value.splice(index, 1)
  } else {
    localGroup.value.push(groupId)
  }
  update()
}

const selectSubject = (subjectId) => {
  localSubject.value = subjectId
  showSubjectsModal.value = false
  update()
}

const save = () => {
  if (localTitle.value && localGroup.value.length && localDescription.value && localSubject.value) {
    emit('save', {
      title: localTitle.value,
      group: localGroup.value,
      description: localDescription.value,
      files: localFiles.value,
      subject_id: localSubject.value,
    })
  } else {
    alert('Заполните все поля!')
  }
}

const groupName = (id) => props.lecturerGroups.find((g) => g.id === id)?.name || id
const subjectName = (id) => props.subjects.find((s) => s.id === id)?.name || id
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.add-lab-modal {
  &__overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: none;
    display: flex;
    justify-content: center;
    align-items: center;
    overflow-y: auto;
    padding: 20px;
    z-index: 1000;
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
    width: 360px;
    gap: 15px;
    transition-duration: $td-02;
    margin: auto;
  }

  &__title {
    text-align: center;
  }

  &__field {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  &__textarea {
    resize: none;
    scrollbar-width: thin;
    scrollbar-color: $color-gray-500 transparent;

    &::-webkit-scrollbar {
      width: 8px;
    }

    &::-webkit-scrollbar-track {
      background: transparent;
      margin: 4px 0;
    }

    &::-webkit-scrollbar-thumb {
      background-color: $color-gray-500;
      border-radius: 4px;
      border: 2px solid transparent;
      background-clip: padding-box;
    }

    &:focus {
      box-shadow: $bs-out-light;
    }
  }

  &__file-label {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 50px;
    background: rgba($color-gray-300, 0.5);
    border: 3px dashed $color-light;
    border-radius: $br-8;
    cursor: pointer;
    transition-duration: $td-02;

    &:hover {
      box-shadow: $bs-out-light;
      background-color: $color-gray-100;
    }
  }

  &__file-input {
    display: none;
  }

  &__files {
    display: flex;
    flex-direction: column;
    gap: 10px;
    max-height: 100px;
    overflow-y: auto;
    padding: 8px;
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

  &__file {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 14px;
    padding: 4px 8px;
    background: $color-light;
    border-radius: 8px;
    transition-duration: $td-02;
    user-select: none;
  }

  &__filename {
    margin-right: 10px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &__remove-btn {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    color: $color-red-500;
    background-color: $color-light;
    cursor: pointer;
    padding: 5px;
    border-radius: $br-8;
    transition-duration: $td-02;

    &:hover,
    &:active {
      background: $color-gray-200;
    }

    svg {
      width: 24px;
      height: 24px;
    }
  }

  &__buttons {
    display: flex;
    justify-content: center;
    gap: 10px;
  }
}

.group-badges-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px;
}

.group-badge {
  background: $color-groups;
  padding: 4px 10px;
  border-radius: 8px;
  font-size: 0.98em;
  margin-right: 0;
  margin-bottom: 0;
  user-select: none;
}

.edit-groups-btn {
  margin-left: 8px;
  padding: 4px 10px;
  font-size: 0.98em;
  background: $color-gray-500;
  border: 1px solid $color-gray-400;
  border-radius: 8px;
  cursor: pointer;
  transition: background $td-02;

  &:hover {
    background: $color-gray-400;
  }
}

.groups-modal__overlay {
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

.groups-modal__content {
  background-color: $color-light;
  box-shadow: 0 0 8px 0 $color-gray-600;
  border: 2px solid $color-gray-600;
  padding: 10px;
  border-radius: $br-8;
  width: 300px;
  display: flex;
  flex-direction: column;
}

.groups-badges-list {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-bottom: 20px;
}

.group-badge-select {
  cursor: pointer;
  background-color: $color-gray-200;
  transition-duration: $td-02;

  &:hover,
  &:active {
    background-color: $color-gray-400;
  }
}

.groups-modal__buttons {
  display: flex;
  justify-content: center;
}

.groups-modal__button {
  font-size: 16px;
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

.modal-fade-content-enter-active,
.modal-fade-content-leave-active {
  transition:
    opacity $td-02,
    transform $td-02;
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

.add-lab-modal__label {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 5px;
  font-size: 16px;
  color: $color-gray-900;
  background-color: $color-gray-300;
  margin-right: auto;
  border-radius: $br-8;
  padding: 3px 6px;

  &--btn {
    padding-block: 10px;
    padding-right: 10px;
  }
}

.add-lab-modal__groups-label {
  color: $color-gray-900;
  cursor: pointer;
  transition-duration: $td-02;

  &:hover,
  &:active {
    background-color: $color-light;
  }
}

.add-lab-modal__groups-selected {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 5px;
  min-height: 29px;
}

.add-lab-modal__subject-label {
  color: $color-gray-900;
  cursor: pointer;
  transition-duration: $td-02;

  &:hover,
  &:active {
    background-color: $color-light;
  }
}

.add-lab-modal__subject-selected {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 5px;
  min-height: 29px;
}

.add-lab-modal__subject-placeholder {
  color: $color-gray-400;
}
</style>
