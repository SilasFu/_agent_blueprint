import { useEffect, useState } from 'react';

function App() {
  const [message, setMessage] = useState('Loading...');

  useEffect(() => {
    const baseUrl = import.meta.env.VITE_API_BASE_URL ?? 'http://127.0.0.1:8000';

    fetch(`${baseUrl}/api/message`)
      .then((response) => response.json())
      .then((data) => setMessage(data.message))
      .catch(() => setMessage('Backend unavailable'));
  }, []);

  return (
    <main style={{ maxWidth: 720, margin: '40px auto', fontFamily: 'sans-serif' }}>
      <h1>React + FastAPI Template</h1>
      <p>{message}</p>
    </main>
  );
}

export default App;