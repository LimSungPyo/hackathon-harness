import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

const apiPort = process.env.API_PORT ?? 3000

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0',
    port: Number(process.env.WEB_PORT ?? 5173),
    strictPort: true,
    // 브라우저는 웹 포트 하나만 알면 된다. /api는 서버로 넘긴다.
    proxy: { '/api': `http://127.0.0.1:${apiPort}` },
  },
})
