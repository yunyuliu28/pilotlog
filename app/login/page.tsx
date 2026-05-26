'use client'

import Link from 'next/link'
import { useState } from 'react'

export default function LoginPage() {
  const [tab, setTab] = useState<'login' | 'signup'>('login')

  return (
    <div className="flex flex-col min-h-screen bg-[#0A0F1E]">
      {/* Hero */}
      <div className="flex flex-col items-center justify-center pt-20 pb-10 px-6">
        <div className="w-16 h-16 rounded-2xl bg-blue-500 flex items-center justify-center mb-4 shadow-lg shadow-blue-500/30">
          <svg width="32" height="32" fill="none" viewBox="0 0 24 24">
            <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z" fill="white"/>
          </svg>
        </div>
        <h1 className="text-white text-3xl font-bold tracking-tight">PilotLog</h1>
        <p className="text-gray-500 text-sm mt-1">Your digital flight logbook</p>
      </div>

      {/* Tab switcher */}
      <div className="mx-6 mb-6">
        <div className="flex bg-[#111827] rounded-xl p-1">
          <button
            onClick={() => setTab('login')}
            className={`flex-1 py-2.5 rounded-lg text-sm font-semibold transition-all ${tab === 'login' ? 'bg-blue-500 text-white shadow' : 'text-gray-400'}`}
          >
            Log In
          </button>
          <button
            onClick={() => setTab('signup')}
            className={`flex-1 py-2.5 rounded-lg text-sm font-semibold transition-all ${tab === 'signup' ? 'bg-blue-500 text-white shadow' : 'text-gray-400'}`}
          >
            Sign Up
          </button>
        </div>
      </div>

      {/* Form */}
      <div className="px-6 flex flex-col gap-4">
        {tab === 'signup' && (
          <div>
            <label className="text-gray-400 text-xs font-medium uppercase tracking-wider mb-1.5 block">Full Name</label>
            <input
              type="text"
              placeholder="John Smith"
              className="w-full bg-[#111827] border border-[#1E2D45] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-blue-500 transition-colors"
            />
          </div>
        )}
        <div>
          <label className="text-gray-400 text-xs font-medium uppercase tracking-wider mb-1.5 block">Email</label>
          <input
            type="email"
            placeholder="pilot@email.com"
            className="w-full bg-[#111827] border border-[#1E2D45] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-blue-500 transition-colors"
          />
        </div>
        <div>
          <label className="text-gray-400 text-xs font-medium uppercase tracking-wider mb-1.5 block">Password</label>
          <input
            type="password"
            placeholder="••••••••"
            className="w-full bg-[#111827] border border-[#1E2D45] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-blue-500 transition-colors"
          />
        </div>

        {tab === 'signup' && (
          <div>
            <label className="text-gray-400 text-xs font-medium uppercase tracking-wider mb-1.5 block">Certificate Type</label>
            <select className="w-full bg-[#111827] border border-[#1E2D45] rounded-xl px-4 py-3.5 text-gray-400 text-sm focus:outline-none focus:border-blue-500 appearance-none">
              <option>Student Pilot</option>
              <option>Private Pilot</option>
              <option>Instrument Rated</option>
              <option>Commercial Pilot</option>
              <option>ATP</option>
            </select>
          </div>
        )}

        {tab === 'login' && (
          <div className="text-right">
            <button className="text-blue-400 text-sm">Forgot password?</button>
          </div>
        )}

        <Link
          href="/dashboard"
          className="w-full bg-blue-500 hover:bg-blue-400 text-white font-semibold py-4 rounded-xl text-center transition-colors shadow-lg shadow-blue-500/20 mt-2"
        >
          {tab === 'login' ? 'Log In' : 'Create Account'}
        </Link>

        <div className="flex items-center gap-3 my-2">
          <div className="flex-1 h-px bg-[#1E2D45]" />
          <span className="text-gray-600 text-xs">or continue with</span>
          <div className="flex-1 h-px bg-[#1E2D45]" />
        </div>

        <button className="w-full bg-[#111827] border border-[#1E2D45] text-white font-medium py-3.5 rounded-xl flex items-center justify-center gap-3 hover:border-gray-600 transition-colors">
          <svg width="18" height="18" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          Continue with Google
        </button>
      </div>
    </div>
  )
}
