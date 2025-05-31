<template>
  <MainLayout>
    <div class="user-profile__content" v-if="!isLoading">
      <div class="user-profile__field">
        <div class="user-profile__field-inner">
          <div class="user-profile__fio">
            <span class="user-profile__fio-label label-style">Фамилия</span>
            <span class="user-profile__fio-value">{{ userInfo.middle_name }}</span>
          </div>
          <div class="user-profile__fio">
            <span class="user-profile__fio-label label-style">Имя</span>
            <span class="user-profile__fio-value">{{ userInfo.first_name }}</span>
          </div>
          <div class="user-profile__fio">
            <span class="user-profile__fio-label label-style">Отчество</span>
            <span class="user-profile__fio-value">{{ userInfo.last_name }}</span>
          </div>
        </div>
      </div>
      <template v-if="userRole === 'student'">
        <div class="user-profile__field">
          <div class="user-profile__field-inner user-profile__field-inner--alt">
            <span class="user-profile__label">Группа</span>
            <span class="user-profile__value user-profile__group item-style item-style--group">{{
              userInfo.group
              }}</span>
          </div>
          <div
               class="user-profile__field-inner user-profile__field-inner--alt user-profile__field-inner--alt-vx">
            <span class="user-profile__label">Оценка</span>
            <div class="user-profile__field-inner--alt-v">
              <p
                 v-for="subject in averageGradesWithClass"
                 :key="subject.subject"
                 class="user-profile__label user-profile__label--alt item-style item-style--subject">
                {{ subject.subject }}
                <span class="item-style item-style--grade" :class="subject.gradeClass">
                  {{ subject.grade !== null ? formatGrade(subject.grade) : '-' }}
                </span>
              </p>
            </div>
          </div>
        </div>
      </template>

      <template v-if="userRole === 'lecturer'">
        <div class="user-profile__field">
          <h3
              role="button"
              :tabindex="0"
              class="user-profile__field-action btn-style"
              @click="toggleModal(true, 'subjects')">
            Предметы
            <OpenIcon class="user-profile__header-icon" />
          </h3>
          <div class="user-profile__footer">
            <div
                 v-for="subject in selectedSubjectsDisplay"
                 :key="subject.id"
                 class="user-profile__footer-item item-style item-style--subject text-nl">
              <span>{{ subject.name }}</span>
            </div>
          </div>
        </div>

        <div class="user-profile__field">
          <h3
              role="button"
              :tabindex="0"
              class="user-profile__field-action btn-style"
              @click="toggleModal(true, 'groups')">
            Группы
            <OpenIcon class="user-profile__header-icon" />
          </h3>
          <div class="user-profile__footer">
            <div
                 v-for="group in selectedGroupsDisplay"
                 :key="group.id"
                 class="user-profile__footer-item item-style item-style--group">
              <span>{{ group.name }}</span>
            </div>
          </div>
        </div>

        <transition name="modal-fade-overlay">
          <div v-if="showSubjectsModal" class="subjects-modal">
            <div class="subjects-modal__content">
              <div class="subjects-modal__header">
                <h3 class="subjects-modal__header-title">Выбор предметов</h3>
                <input
                       type="text"
                       v-model="subjectSearch"
                       placeholder="Поиск предметов..."
                       class="input-style"
                       id="subject-search"
                       name="subject-search" />
              </div>
              <div class="subjects-modal__list">
                <div
                     v-for="subject in filteredSubjects"
                     :key="subject.id"
                     class="subjects-modal-item"
                     :class="{
                      'subjects-modal-item--selected item-style--subject':
                        tempSelectedSubjects.includes(subject.id),
                    }">
                  <label
                         class="subject-modal-label item-style text-nl"
                         :for="'subject-' + subject.id">
                    <input
                           type="checkbox"
                           :id="'subject-' + subject.id"
                           :name="'subject-' + subject.id"
                           :value="subject.id"
                           v-model="tempSelectedSubjects" />
                    {{ subject.name }}
                  </label>
                </div>
              </div>
              <div class="subjects-modal__footer">
                <button
                        @click="saveSubjects"
                        class="btn-style btn-style--modal"
                        id="save-subjects-modal"
                        name="save-subjects-modal">
                  Сохранить
                </button>
                <button
                        @click="toggleModal(false, 'subjects')"
                        class="btn-style btn-style--modal"
                        id="close-subjects-modal"
                        name="close-subjects-modal">
                  Закрыть
                </button>
              </div>
            </div>
          </div>
        </transition>

        <transition name="modal-fade-overlay">
          <div v-if="showGroupsModal" class="subjects-modal">
            <div class="subjects-modal__content">
              <div class="subjects-modal__header">
                <h3 class="subjects-modal__header-title">Выбор групп</h3>
                <input
                       type="text"
                       v-model="groupSearch"
                       placeholder="Поиск групп..."
                       class="input-style"
                       id="group-search"
                       name="group-search" />
              </div>
              <div class="subjects-modal__list">
                <div
                     v-for="group in filteredGroups"
                     :key="group.id"
                     class="subjects-modal-item"
                     :class="{
                      'subjects-modal-item--selected item-style--group': tempSelectedGroups.includes(
                        group.id,
                      ),
                    }">
                  <label class="subject-modal-label item-style text-nl" :for="'group-' + group.id">
                    <input
                           type="checkbox"
                           :id="'group-' + group.id"
                           :name="'group-' + group.id"
                           :value="group.id"
                           v-model="tempSelectedGroups" />
                    {{ group.name }}
                  </label>
                </div>
              </div>
              <div class="subjects-modal__footer">
                <button
                        @click="saveGroups"
                        class="btn-style btn-style--modal"
                        id="save-groups-modal"
                        name="save-groups-modal">
                  Сохранить
                </button>
                <button
                        @click="toggleModal(false, 'groups')"
                        class="btn-style btn-style--modal"
                        id="close-groups-modal"
                        name="close-groups-modal">
                  Закрыть
                </button>
              </div>
            </div>
          </div>
        </transition>
      </template>

      <div class="user-profile__field">
        <div class="user-profile__field-wrapper">
          <div>
            <form @submit.prevent="changePassword" class="password-form">
              <h3 class="user-profile__field-action label-style">Изменение пароля</h3>
              <div class="password-form__field">
                <label for="currentPassword" class="password-form__field-label">Текущий пароль</label>
                <div class="password-form__input-container">
                  <input :type="showCurrentPassword ? 'text' : 'password'" id="currentPassword"
                         v-model="passwordForm.currentPassword" class="input-style-alt" autocomplete="off" />
                  <button type="button" class="password-form__toggle"
                          @click="showCurrentPassword = !showCurrentPassword">
                    <EyeFillIcon v-if="showCurrentPassword" />
                    <EyeOffIcon v-else />
                  </button>
                </div>
              </div>
              <div class="password-form__field">
                <label for="newPassword" class="password-form__field-label">Новый пароль</label>
                <div class="password-form__input-container">
                  <input :type="showNewPassword ? 'text' : 'password'" id="newPassword"
                         v-model="passwordForm.newPassword"
                         class="input-style-alt" autocomplete="off" />
                  <button type="button" class="password-form__toggle" @click="showNewPassword = !showNewPassword">
                    <EyeFillIcon v-if="showNewPassword" />
                    <EyeOffIcon v-else />
                  </button>
                </div>
              </div>
              <div class="password-form__field">
                <label for="confirmPassword" class="password-form__field-label">Подтвердите пароль</label>
                <div class="password-form__input-container">
                  <input :type="showConfirmPassword ? 'text' : 'password'" id="confirmPassword"
                         v-model="passwordForm.confirmPassword" class="input-style-alt" autocomplete="off" />
                  <button type="button" class="password-form__toggle"
                          @click="showConfirmPassword = !showConfirmPassword">
                    <EyeFillIcon v-if="showConfirmPassword" />
                    <EyeOffIcon v-else />
                  </button>
                </div>
              </div>
              <button type="submit" class="password-form__submit btn-style">Сохранить</button>
            </form>
          </div>
          <div>
            <form @submit.prevent="changeEmail" class="password-form">
              <h3 class="user-profile__field-action label-style">Изменение почты</h3>
              <div class="password-form__field">
                <label for="currentEmail" class="password-form__field-label">Текущая почта</label>
                <div class="password-form__input-container">
                  <input id="currentEmail" type="email" v-model="emailForm.currentEmail" class="input-style-alt"
                         autocomplete="off" />
                </div>
              </div>
              <div class="password-form__field">
                <label for="newEmail" class="password-form__field-label">Новая почта</label>
                <div class="password-form__input-container">
                  <input id="newEmail" type="email" v-model="emailForm.newEmail" class="input-style-alt"
                         autocomplete="off" />
                </div>
              </div>

              <button type="submit" class="password-form__submit btn-style">Сохранить</button>
            </form>
          </div>
        </div>
      </div>
      <button @click="goBack" class="back-btn btn-style">
        <BackPageIcon class="back-btn__icon" />
      </button>
    </div>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import MainLayout from '../MainLayout/MainLayout.vue'
import authStore from '@/stores/auth.store.js'
import userProfileService from './api'
import BackPageIcon from '@/assets/icons/BackPageIncon.vue'
import EyeFillIcon from '@/assets/icons/EyeFillIcon.vue'
import EyeOffIcon from '@/assets/icons/EyeOffIcon.vue'
import OpenIcon from '@/assets/icons/OpenIcon.vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const isLoading = ref(true)
const tempSelectedSubjects = ref([])
const tempSelectedGroups = ref([])

const goBack = () => {
  router.go(-1)
}

const showSubjectsModal = ref(false)
const showGroupsModal = ref(false)

const subjectSearch = ref('')
const groupSearch = ref('')

const filteredSubjects = computed(() =>
  availableSubjects.value.filter((subject) =>
    subject.name.toLowerCase().includes(subjectSearch.value.toLowerCase()),
  ),
)

const filteredGroups = computed(() =>
  availableGroups.value.filter((group) =>
    group.name.toLowerCase().includes(groupSearch.value.toLowerCase()),
  ),
)

const toggleModal = (state, modal) => {
  if (modal === 'subjects') {
    showSubjectsModal.value = state
    if (state) {
      tempSelectedSubjects.value = [...selectedSubjects.value]
    } else {
      subjectSearch.value = ''
    }
  }
  if (modal === 'groups') {
    showGroupsModal.value = state
    if (state) {
      tempSelectedGroups.value = [...selectedGroups.value]
    } else {
      groupSearch.value = ''
    }
  }
}

const availableSubjects = ref([])
const selectedSubjects = ref([])

const availableGroups = ref([])
const selectedGroups = ref([])

const userInfo = ref({})

const selectedSubjectsDisplay = computed(() =>
  selectedSubjects.value
    .map((subjectId) => availableSubjects.value.find((subject) => subject.id === subjectId))
    .filter(Boolean),
)

const selectedGroupsDisplay = computed(() =>
  selectedGroups.value
    .map((groupId) => availableGroups.value.find((group) => group.id === groupId))
    .filter(Boolean),
)

const averageGrades = ref([])

const fetchUserData = async () => {
  try {
    const { data } = await userProfileService.getUserProfile()
    userInfo.value = data.user
    averageGrades.value = data.averageGrades || []
    selectedSubjects.value = (data.selectedSubjects || []).map((subject) => subject.id)
    availableSubjects.value = data.availableSubjects || []
    selectedGroups.value = (data.selectedGroups || []).map((group) => group.id)
    availableGroups.value = data.availableGroups || []
  } catch (error) {
    alert('Не удалось загрузить данные профиля: ' + error.response.data.message || error)
  }
}

const saveSubjects = async () => {
  try {
    await userProfileService.updateSubjects(tempSelectedSubjects.value)
    selectedSubjects.value = [...tempSelectedSubjects.value]
    toggleModal(false, 'subjects')
  } catch (error) {
    alert('Ошибка при обновлении предметов:' + error.response.data.message || error)
  }
}

const saveGroups = async () => {
  try {
    await userProfileService.updateGroups(tempSelectedGroups.value)
    selectedGroups.value = [...tempSelectedGroups.value]
    toggleModal(false, 'groups')
  } catch (error) {
    alert('Не удалось обновить группы: ' + error.response.data.message || error)
  }
}

const userRole = computed(() => authStore.user?.role ?? '')

onMounted(async () => {
  try {
    await fetchUserData()
    isLoading.value = false
  } catch (error) {
    alert('Ошибка при загрузке: ' + error.response.data.message || error)
  }
})

const getGradeClass = (grade) => {
  if (grade === null || grade === undefined) return 'item-style--grade-null'
  if (grade >= 1.75) return 'item-style--grade-2'
  if (grade >= 1.25) return 'item-style--grade-15'
  if (grade >= 0.75) return 'item-style--grade-1'
  if (grade >= 0.25) return 'item-style--grade-05'
  if (grade >= 0) return 'item-style--grade-0'
  return 'item-style--grade-null'
}

const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const showCurrentPassword = ref(false)
const showNewPassword = ref(false)
const showConfirmPassword = ref(false)

const changePassword = async () => {
  if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
    alert('Пароли не совпадают')
    return
  }

  try {
    await userProfileService.changePassword({
      currentPassword: passwordForm.value.currentPassword,
      newPassword: passwordForm.value.newPassword,
    })
    alert('Пароль успешно изменён')
    passwordForm.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
    }
  } catch (error) {
    alert('Ошибка при смене пароля: ' + extractErrorMessage(error))
  }
}

const extractErrorMessage = (e) => {
  if (Array.isArray(e?.response?.data?.message)) {
    return e.response.data.message.map((m) => `${m.path}: ${m.msg}`).join('\n')
  }
  return e?.response?.data?.message || e?.message || JSON.stringify(e) || 'Неизвестная ошибка'
}

const averageGradesWithClass = computed(() => {
  return averageGrades.value.map((subject) => ({
    ...subject,
    gradeClass: getGradeClass(subject.grade != null ? Number(subject.grade) : null),
  }))
})

const emailForm = ref({
  currentEmail: '',
  newEmail: '',
})

const changeEmail = async () => {
  if (!emailForm.value.currentEmail || !emailForm.value.newEmail) {
    alert('Пожалуйста, заполните все поля')
    return
  }

  try {
    await userProfileService.changeEmail({
      currentEmail: emailForm.value.currentEmail,
      newEmail: emailForm.value.newEmail,
    })
    alert('Почта успешно изменена')
    emailForm.value = {
      currentEmail: '',
      newEmail: '',
    }
  } catch (error) {
    alert('Ошибка при изменении почты: ' + error.response.data.message || error)
  }
}

const formatGrade = (grade) => {
  const numericGrade = Number(grade)

  if (isNaN(numericGrade)) return '-'

  return Number.isInteger(numericGrade) ? numericGrade : numericGrade.toFixed(1)
}
</script>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.user-profile {
  &__content {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  &__field {
    display: flex;
    justify-content: center;
    flex-direction: column;
    gap: 10px;

    &-inner {
      display: flex;
      justify-content: center;
      flex-wrap: wrap;
      gap: 5px;

      &--alt {
        align-items: center;
        justify-content: start;

        &-v {
          display: flex;
          justify-content: start;
          align-items: center;
          gap: 10px;
          flex-wrap: wrap;
        }

        &-vx {
          flex-direction: column;
          align-items: start;
        }
      }
    }

    &--alt {
      flex-direction: row;
      gap: 40px;
    }

    &-action {
      user-select: none;
      -webkit-user-select: none;
      -moz-user-select: none;
      -ms-user-select: none;
      display: flex;
      justify-content: space-between;
      align-items: center;
      text-align: center;
      gap: 20px;
      width: 186px;
      cursor: pointer;
    }

    &:not(:last-child)::after {
      content: '';
      align-self: center;
      width: 90%;
      margin-top: 10px;
      border: 2px solid $color-gray-300;
      border-radius: $br-8;
    }

    &-wrapper {
      display: flex;
      justify-content: space-between;
      flex-direction: row;
      flex-wrap: wrap;
      gap: 20px;
    }
  }

  &__footer {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    font-size: 20px;
  }

  &__fio {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 10px;

    &-label {
      font-size: 24px;
      font-weight: 500;
      padding: 5px;
    }

    &-value {
      font-size: 20px;
      padding: 5px;
    }
  }

  &__label {
    display: flex;
    justify-content: space-around;
    align-items: center;
    gap: 10px;
    font-size: 18px;
    font-weight: 600;
    color: $color-dark;
  }

  &__value {
    color: $color-dark;
    font-size: 18px;
  }

  &__grade {
    padding: 4px 12px;
    border-radius: 8px;
    font-weight: 500;
    border: 2.5px solid transparent;
  }
}

.password-form {
  display: flex;
  justify-content: center;
  align-items: start;
  flex-direction: column;
  width: 250px;
  gap: 10px;

  &__field {
    display: flex;
    justify-content: center;
    flex-direction: column;
    gap: 2px;

    &-label {
      font-size: 18px;
    }
  }

  &__input-container {
    position: relative;
    display: flex;
    align-items: center;
    width: 250px;

    input {
      width: inherit;
    }

    svg {
      width: 20px;
      height: 20px;
    }
  }

  &__toggle {
    position: absolute;
    right: 5px;
    padding: 5px;
    color: $color-gray-600;
    transition-duration: $td-02;
    height: 100%;
    background: none;
    border: none;
    cursor: pointer;

    &:hover {
      color: $color-dark;
    }
  }

  &__submit {
    align-self: center;
  }
}

.subjects-modal {
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

  &__header {
    display: flex;
    flex-direction: column;
    gap: 15px;
    text-align: center;

    &-title {
      font-size: 24px;
    }
  }

  &__list {
    user-select: none;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    display: flex;
    flex-wrap: wrap;
    max-height: 100px;
    overflow-y: auto;
    gap: 10px;
    padding: 8px;

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
  }

  &__footer {
    display: flex;
    justify-content: center;
    gap: 20px;
  }

  &-item {
    font-size: 18px;
    transition-duration: $td-02;
    background-color: $color-light;
    text-align: center;
    cursor: pointer;

    &:hover {
      box-shadow: $bs-out-light;
    }

    &--selected {
      &:hover {
        box-shadow: $bs-out-dark;
      }
    }

    label {
      cursor: pointer;

      input[type='checkbox'] {
        display: none;
      }
    }
  }
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

.back-btn {
  position: absolute;
  top: 6px;
  left: 6px;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;

  &__icon {
    width: 22px;
    height: 22px;
  }
}

.subjects-modal-item {
  border-radius: $br-8;
}

.subject-modal-label {
  display: flex;
}
</style>
