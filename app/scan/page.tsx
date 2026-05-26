'use client'

import Link from 'next/link'
import { useState } from 'react'
import BottomNav from '@/components/BottomNav'

const mockExtracted = [
  { date: '03/09/25', aircraft: 'C172', ident: 'N4166L', from: 'FAI', to: 'CXF', total: '4.2', pic: '4.2', xc: '4.2', ldg: '2', remarks: 'C172 CXF' },
  { date: '03/07/25', aircraft: 'PA-31-350', ident: 'N5LIVA', from: 'FAI', to: 'CXF', total: '2.5', pic: '2.5', xc: '2.5', ldg: '2', remarks: 'JA' },
]

export default function ScanPage() {
  const [state, setState] = useState<'idle' | 'scanning' | 'review'>('idle')

  return (
    <div className="flex flex-col min-h-screen bg-[#0A0F1E] pb-28">
      {/* Header */}
      <div className="px-5 pt-14 pb-4 bg-gradient-to-b from-[#0D1B35] to-[#0A0F1E]">
        <div className="flex items-center gap-3">
          <Link href="/dashboard" className="w-9 h-9 rounded-xl bg-[#111827] border border-[#1E2D45] flex items-center justify-center">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24">
              <path d="M19 12H5M11 6l-6 6 6 6" stroke="#9CA3AF" strokeWidth="2" strokeLinecap="round"/>
            </svg>
          </Link>
          <div>
            <h1 className="text-white text-xl font-bold">Scan Logbook</h1>
            <p className="text-gray-500 text-xs">AI-powered page extraction</p>
          </div>
        </div>
      </div>

      <div className="px-5">
        {state === 'idle' && (
          <>
            {/* Upload area */}
            <div
              onClick={() => setState('scanning')}
              className="mt-2 border-2 border-dashed border-[#1E2D45] rounded-3xl p-10 flex flex-col items-center justify-center gap-4 cursor-pointer hover:border-blue-500/50 hover:bg-[#111827]/50 transition-all"
            >
              <div className="w-16 h-16 rounded-2xl bg-[#111827] border border-[#1E2D45] flex items-center justify-center">
                <svg width="28" height="28" fill="none" viewBox="0 0 24 24">
                  <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" stroke="#3B82F6" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  <circle cx="12" cy="13" r="4" stroke="#3B82F6" strokeWidth="1.5"/>
                </svg>
              </div>
              <div className="text-center">
                <p className="text-white font-semibold">Take a photo</p>
                <p className="text-gray-500 text-sm mt-1">or tap to upload from library</p>
              </div>
            </div>

            <div className="flex items-center gap-3 my-5">
              <div className="flex-1 h-px bg-[#1E2D45]" />
              <span className="text-gray-600 text-xs">or</span>
              <div className="flex-1 h-px bg-[#1E2D45]" />
            </div>

            {/* Tips */}
            <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45]">
              <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold mb-3">Tips for best results</p>
              {[
                'Lay the logbook flat before scanning',
                'Ensure good lighting, avoid shadows',
                'Capture the full page width',
                'You can review and correct before saving',
              ].map((tip, i) => (
                <div key={i} className="flex items-start gap-2.5 mb-2 last:mb-0">
                  <div className="w-4 h-4 rounded-full bg-blue-500/20 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-blue-400 text-[9px] font-bold">{i + 1}</span>
                  </div>
                  <p className="text-gray-400 text-xs leading-relaxed">{tip}</p>
                </div>
              ))}
            </div>
          </>
        )}

        {state === 'scanning' && (
          <div className="flex flex-col items-center justify-center py-20 gap-6">
            {/* Spinner */}
            <div className="relative w-20 h-20">
              <div className="absolute inset-0 rounded-full border-4 border-[#1E2D45]" />
              <div className="absolute inset-0 rounded-full border-4 border-t-blue-500 animate-spin" />
              <div className="absolute inset-0 flex items-center justify-center">
                <svg width="24" height="24" fill="none" viewBox="0 0 24 24">
                  <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z" fill="#3B82F6"/>
                </svg>
              </div>
            </div>
            <div className="text-center">
              <p className="text-white font-semibold">Reading your logbook...</p>
              <p className="text-gray-500 text-sm mt-1">AI is extracting flight entries</p>
            </div>
            <button
              onClick={() => setState('review')}
              className="px-8 py-3 bg-[#111827] border border-[#1E2D45] rounded-xl text-gray-400 text-sm"
            >
              Simulate result →
            </button>
          </div>
        )}

        {state === 'review' && (
          <>
            <div className="flex items-center gap-2 mb-4 bg-emerald-500/10 border border-emerald-500/20 rounded-xl p-3">
              <svg width="16" height="16" fill="none" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="9" stroke="#10B981" strokeWidth="2"/>
                <path d="M8 12l3 3 5-5" stroke="#10B981" strokeWidth="2" strokeLinecap="round"/>
              </svg>
              <p className="text-emerald-400 text-xs font-medium">Found {mockExtracted.length} flight entries — review before saving</p>
            </div>

            {mockExtracted.map((entry, i) => (
              <div key={i} className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] mb-3">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className="text-white font-semibold text-sm">{entry.date}</span>
                    <span className="text-gray-500 text-xs">·</span>
                    <span className="text-gray-400 text-xs">{entry.aircraft} {entry.ident}</span>
                  </div>
                  <button className="text-gray-600 hover:text-gray-400">
                    <svg width="14" height="14" fill="none" viewBox="0 0 24 24">
                      <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                      <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                    </svg>
                  </button>
                </div>
                <div className="grid grid-cols-4 gap-2">
                  {[
                    { label: 'Route', value: `${entry.from}→${entry.to}` },
                    { label: 'Total', value: entry.total },
                    { label: 'PIC', value: entry.pic },
                    { label: 'XC', value: entry.xc },
                    { label: 'Landings', value: entry.ldg },
                    { label: 'Remarks', value: entry.remarks },
                  ].map((field) => (
                    <div key={field.label} className={field.label === 'Remarks' ? 'col-span-3' : ''}>
                      <p className="text-gray-600 text-[9px] uppercase tracking-wider">{field.label}</p>
                      <p className="text-white text-xs font-medium mt-0.5">{field.value}</p>
                    </div>
                  ))}
                </div>
              </div>
            ))}

            <div className="flex gap-3 mt-2">
              <button
                onClick={() => setState('idle')}
                className="flex-1 py-3.5 rounded-2xl border border-[#1E2D45] text-gray-400 text-sm font-medium"
              >
                Discard
              </button>
              <Link
                href="/logbook"
                className="flex-1 py-3.5 rounded-2xl bg-blue-500 text-white text-sm font-semibold text-center shadow-lg shadow-blue-500/20"
              >
                Save {mockExtracted.length} Flights
              </Link>
            </div>
          </>
        )}
      </div>

      <BottomNav />
    </div>
  )
}
