import AuthForm from '../components/AuthForm'

export default function Home() {
  return (
    <main style={{ minHeight: '100vh', background: '#0b0f19', color: '#fff', padding: '20px' }}>
      <h1 style={{ textAlign: 'center', marginTop: '20px' }}>Global Community-তে স্বাগতম</h1>
      <AuthForm />
    </main>
  )
}
