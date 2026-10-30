import express from 'express'

const app = express()
const port = Number(process.env.API_PORT ?? 3000)
const startedAt = new Date().toISOString()

app.use(express.json())

// pid와 시작 시각을 함께 돌려준다. 재시작 뒤 응답한 게 새 프로세스인지 구분하려고.
app.get('/api/health', (req, res) => {
  res.json({ ok: true, pid: process.pid, startedAt })
})

app.use('/api', (req, res) => {
  res.status(404).json({ error: 'not_found' })
})

// 오류 본문에 요청 헤더나 키가 섞일 수 있어 로그에는 종류만 남긴다.
app.use((err, req, res, next) => {
  console.error(`[${req.method} ${req.path}]`, err.name)
  res.status(err.status ?? 500).json({ error: err.expose ? err.message : 'internal_error' })
})

app.listen(port, '0.0.0.0', () => {
  console.log(`api listening on 0.0.0.0:${port} (pid ${process.pid})`)
})
