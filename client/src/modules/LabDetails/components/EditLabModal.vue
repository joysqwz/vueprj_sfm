<template>
  <transition name="modal-fade-overlay">
    <div v-if="show" class="edit-lab-modal__overlay">
      <div class="edit-lab-modal__content">
        <h2 class="edit-lab-modal__title">Редактирование</h2>
        <form class="edit-lab-modal__form">
          <div class="edit-lab-modal__field">
            <label for="lab-title" class="edit-lab-modal__label">Заголовок</label>
            <input
              id="lab-title"
              v-model="localLab.title"
              type="text"
              class="input-style"
              placeholder="Введите заголовок ЛБ"
            />
          </div>
          <div class="edit-lab-modal__field">
            <label for="lab-description" class="edit-lab-modal__label">Описание</label>
            <textarea
              id="lab-description"
              v-model="localLab.description"
              class="edit-lab-modal__textarea textarea-style"
              placeholder="Введите описание ЛБ"
            ></textarea>
          </div>
          <div class="edit-lab-modal__field">
            <span class="edit-lab-modal__label" for="files">Файлы</span>
            <div
              v-if="localLab.existingFiles?.length || localFiles?.length"
              class="edit-lab-modal__files"
            >
              <div
                v-for="(file, index) in localLab.existingFiles"
                :key="file"
                class="edit-lab-modal__file"
              >
                <span class="edit-lab-modal__filename">{{ file }}</span>
                <button type="button" class="edit-lab-modal__remove-btn" @click="removeFile(index)">
                  <DeleteIcon />
                </button>
              </div>
              <div
                v-for="(file, index) in localFiles"
                :key="file.name"
                class="edit-lab-modal__file edit-lab-modal__file--new"
              >
                <span class="edit-lab-modal__filename">{{ file.name }}</span>
                <button
                  type="button"
                  class="edit-lab-modal__remove-btn"
                  @click="removeNewFile(index)"
                >
                  <DeleteIcon />
                </button>
              </div>
            </div>
            <div v-else class="edit-lab-modal__no-files">Нет загруженных файлов</div>
            <label for="file-upload" class="edit-lab-modal__file-label">
              <span>Загрузить файлы</span>
            </label>
            <input
              id="file-upload"
              type="file"
              multiple
              accept=".pdf,.doc,.docx,.png,.jpeg,.jpg,.txt"
              class="edit-lab-modal__file-input"
              @change="handleFileUpload"
            />
          </div>
        </form>
        <div class="edit-lab-modal__buttons">
          <button class="edit-lab-modal__button btn-style btn-style--modal" @click="saveChanges">
            Сохранить
          </button>
          <button class="edit-lab-modal__button btn-style btn-style--modal" @click="closeModal">
            Отмена
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, watch } from 'vue'
import DeleteIcon from '@/assets/icons/DeleteIcon.vue'

const props = defineProps({
  show: {
    type: Boolean,
    required: true,
  },
  initialLab: {
    type: Object,
    default: () => ({}),
  },
  initialFiles: {
    type: Array,
    default: () => [],
  },
})

const emit = defineEmits(['close', 'save'])

const MAX_FILES = 10
const MAX_FILE_SIZE = 10 * 1024 * 1024

const localLab = ref({
  title: '',
  description: '',
  existingFiles: [],
})
const localFiles = ref([])
const filesToDelete = ref([])
const initialState = ref({})

watch(
  () => props.show,
  (newVal) => {
    if (newVal) {
      saveInitialState()
    }
  },
)

const saveInitialState = () => {
  initialState.value = {
    title: props.initialLab.title || '',
    description: props.initialLab.description || '',
    existingFiles: Array.isArray(props.initialLab.files)
      ? props.initialLab.files.map((file) => file?.file_name).filter(Boolean)
      : [],
  }
  localLab.value = {
    ...initialState.value,
    existingFiles: [...initialState.value.existingFiles],
  }
  localFiles.value = [...(props.initialFiles || [])]
  filesToDelete.value = []
}

const closeModal = () => {
  localLab.value = { title: '', description: '', existingFiles: [] }
  localFiles.value = []
  filesToDelete.value = []
  initialState.value = {}
  emit('close')
}

const handleFileUpload = (event) => {
  const files = Array.from(event.target.files)
  if (!files.length) return

  const existingFileNames = [
    ...localLab.value.existingFiles,
    ...localFiles.value.map((file) => file.name),
  ]

  const validFiles = []
  for (const file of files) {
    if (file.size > MAX_FILE_SIZE) {
      alert(
        `Файл "${file.name}" превышает максимальный размер ${MAX_FILE_SIZE / (1024 * 1024)} МБ.`,
      )
      return
    }
    if (existingFileNames.includes(file.name)) {
      alert(`Файл "${file.name}" уже добавлен.`)
      continue
    }
    validFiles.push(file)
  }

  if (
    validFiles.length + localFiles.value.length + localLab.value.existingFiles.length >
    MAX_FILES
  ) {
    alert(`Максимальное количество файлов: ${MAX_FILES}.`)
    return
  }

  localFiles.value = [...localFiles.value, ...validFiles]
}

const removeFile = (index) => {
  const fileName = localLab.value.existingFiles[index]
  if (fileName) {
    filesToDelete.value = [...filesToDelete.value, fileName]
    localLab.value.existingFiles = localLab.value.existingFiles.filter((_, i) => i !== index)
  }
}

const removeNewFile = (index) => {
  const file = localFiles.value[index]
  if (file) {
    filesToDelete.value = [...filesToDelete.value, file.name]
    localFiles.value = localFiles.value.filter((_, i) => i !== index)
  }
}

const saveChanges = () => {
  const changed = {}

  if (localLab.value.title !== initialState.value.title) {
    changed.title = localLab.value.title
  }
  if (localLab.value.description !== initialState.value.description) {
    changed.description = localLab.value.description
  }

  changed.existingFiles = [...localLab.value.existingFiles]
  if (localLab.value.existingFiles.length === 0 && filesToDelete.value.length > 0) {
    changed.deleteAllFiles = true
  }

  emit('save', changed, localFiles.value)
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.edit-lab-modal {
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
    width: 360px;
    gap: 15px;
    transition-duration: $td-02;
  }

  &__title {
    text-align: center;
  }

  &__form {
    display: flex;
    flex-direction: column;
    gap: 15px;
  }

  &__field {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  &__input {
    padding: 8px;
    border: 1px solid $color-gray-500;
    border-radius: $br-8;
    font-size: 16px;
  }

  &__textarea {
    resize: none;
    scrollbar-width: thin;
    scrollbar-color: $color-gray-500 transparent;
    height: 100px;

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
    margin-block: 10px;
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

  &__no-files {
    color: $color-gray-600;
    font-size: 14px;
    text-align: center;
    padding: 10px;
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

    &--new {
      background: $color-green-100;
    }
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

  &__button {
    padding: 10px 20px;
    border: none;
    border-radius: $br-8;
    cursor: pointer;
    font-size: 16px;
    transition-duration: $td-02;

    &--save {
      background-color: $color-blue-500;
      color: $color-light;

      &:hover {
        background-color: $color-blue-600;
      }
    }

    &--cancel {
      background-color: $color-gray-300;
      color: $color-gray-900;

      &:hover {
        background-color: $color-gray-200;
      }
    }
  }

  &__label {
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
  }

  &__close-btn {
    position: absolute;
    top: 10px;
    right: 10px;
    background: none;
    border: none;
    cursor: pointer;
    font-size: 1.2rem;
    color: $color-gray-900;
  }
}

.modal-fade-overlay-enter-active,
.modal-fade-overlay-leave-active {
  transition: opacity $td-03;
}

.modal-fade-overlay-enter-from,
.modal-fade-overlay-leave-to {
  opacity: 0;
}

.modal-fade-overlay-enter-to,
.modal-fade-overlay-leave-from {
  opacity: 1;
}
</style>
