import AuthForm from '../components/AuthForm';
import Link from 'next/link';

export default function Home() {
  return (
    <main style={{ minHeight: '100vh', padding: '20px' }}>
      <h1 style={{ textAlign: 'center' }}>Global Community</h1>
      
      <div style={{ display: 'flex', gap: '20px', justifyContent: 'center', marginTop: '20px', flexWrap: 'wrap' }}>
        <Link href="/community" style={{ textDecoration: 'none' }}>
          <div style={{ padding: '20px', background: '#111827', color: '#fff', borderRadius: '12px', border: '1px solid #1f2937', cursor: 'pointer', width: '220px' }}>
            <h3>Global Community</h3>
            <p style={{ fontSize: '14px', color: '#9ca3af' }}>Connect and share ideas.</p>
          </div>
        </Link>

        <Link href="/ai-assistant" style={{ textDecoration: 'none' }}>
          <div style={{ padding: '20px', background: '#111827', color: '#fff', borderRadius: '12px', border: '1px solid #1f2937', cursor: 'pointer', width: '220px' }}>
            <h3>AI Assistant</h3>
            <p style={{ fontSize: '14px', color: '#9ca3af' }}>Helpful AI-powered tools.</p>
          </div>
        </Link>
      </div>

      <div style={{ marginTop: '30px' }}>
        <AuthForm />
      </div>
    </main>
  );
}
