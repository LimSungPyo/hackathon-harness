import { useEffect, useState } from 'react'

// 스캐폴드 연결 확인용. 과제 화면을 만들 때 지운다.
export default function App() {
  const [health, setHealth] = useState('확인 중')

  useEffect(() => {
    fetch('/api/health')
      .then((res) => res.json())
      .then((body: { pid: number }) => setHealth(`API 연결됨 (pid ${body.pid})`))
      .catch(() => setHealth('API에 닿지 않음'))
  }, [])

  return (
    <main>
      <p data-testid="health">{health}</p>
    </main>
  )
}
