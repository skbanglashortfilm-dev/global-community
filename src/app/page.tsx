import AuthForm from '../components/AuthForm';
import Link from 'next/link';

export default function Home() {
  return (
    <main style={{ minHeight: '100vh', padding: '20px' }}>
      <h1 style={{ textAlign: 'center' }}>Global Community</h1>
      
      <div style={{ display: 'flex', gap: '20px', justifyContent: 'center', marginTop: '20px' }}>
        <Link href="/community" style={{ padding: '10px 20px', background: '#1f2937', color: '#fff', borderRadius: '8px', textDecoration: 'none' }}>
          Global Community
        </Link>
        <Link href="/ai-assistant" style={{ padding: '10px 20px', background: '#1f2937', color: '#fff', borderRadius: '8px', textDecoration: 'none' }}>
          AI Assistant
        </Link>
      </div>

      <div style={{ marginTop: '30px' }}>
        <AuthForm />
      </div>
    </main>
  );
}
