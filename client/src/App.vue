<script setup>
import { onMounted } from 'vue'
import { deviceIdManager } from './helpers/deviceIdManager'
import { RouterView } from 'vue-router'

onMounted(() => {
  deviceIdManager.getOrSet()
})
</script>

<template>
  <RouterView />
</template>

<style lang="scss">
@use '@/assets/styles/variables' as *;

body {
  background-color: $color-light;
  background-image:
    linear-gradient(to right, $color-gray-100 1px, transparent 1px),
    linear-gradient(to bottom, $color-gray-100 1px, transparent 1px);
  background-size: 20px 20px;
}
</style>
