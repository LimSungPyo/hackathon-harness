<script setup>
import { onMounted, ref } from 'vue'

// 스캐폴드 연결 확인용. 과제 화면을 만들 때 지운다.
const health = ref('확인 중')

onMounted(async () => {
  try {
    const res = await fetch('/api/health')
    const body = await res.json()
    health.value = `API 연결됨 (pid ${body.pid})`
  } catch {
    health.value = 'API에 닿지 않음'
  }
})
</script>

<template>
  <main>
    <p data-testid="health">{{ health }}</p>
  </main>
</template>
