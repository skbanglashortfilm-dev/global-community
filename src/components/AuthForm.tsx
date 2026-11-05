'use client'
import { useState } from 'react'
import { supabase } from '../lib/supabase'

export default function AuthForm() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')

  const handleAuth = async (isSignUp: boolean) => {
    setLoading(true)
    setMessage('')
    try {
      if (isSignUp) {
        const { error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
        setMessage('সফলভাবে রেজিস্ট্রেশন হয়েছে! ইমেইল চেক করুন।')
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
        setMessage('লগইন সফল হয়েছে!')
      }
    } catch (error: any) {
      setMessage(error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ maxWidth: '400px', margin: '50px auto', padding: '20px', background: '#111827', color: '#fff', borderRadius: '8px' }}>
      <h2>Global Community</h2>
      <input
        type="email"
        placeholder="ইমেইল দিন"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        style={{ width: '100%', padding: '10px', margin: '10px 0', background: '#1f2937', color: '#fff', border: 'none', borderRadius: '4px' }}
      />
      <input
        type="password"
        placeholder="পাসওয়ার্ড দিন"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        style={{ width: '100%', padding: '10px', margin: '10px 0', background: '#1f2937', color: '#fff', border: 'none', borderRadius: '4px' }}
      />
      <div style={{ display: 'flex', gap: '10px', marginTop: '10px' }}>
        <button
          onClick={() => handleAuth(false)}
          disabled={loading}
          style={{ flex: 1, padding: '10px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer' }}
        >
          লগইন
        </button>
        <button
          onClick={() => handleAuth(true)}
          disabled={loading}
          style={{ flex: 1, padding: '10px', background: '#16a34a', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer' }}
        >
          সাইন আপ
        </button>
      </div>
      {message && <p style={{ marginTop: '15px', textAlign: 'center' }}>{message}</p>}
    </div>
  )
}
