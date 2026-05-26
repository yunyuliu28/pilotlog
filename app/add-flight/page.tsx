'use client'

import Link from 'next/link'
import { useState } from 'react'
import BottomNav from '@/components/BottomNav'

function TimeInput({ label, name }: { label: string; name: string }) {
  return (
    <div className="flex flex-col gap-1.5">
      <label className="text-gray-500 text-[10px] uppercase tracking-wider font-medium">{label}</label>
      <input
        type="number"
        name={name}
        step="0.1"
        min="0"
        placeholder="0.0"
        className="bg-[#0D1424] border border-[#1E2D45] rounded-xl px-3 py-2.5 text-white text-sm text-center focus:outline-none focus:border-blue-500 transition-colors w-full"
      />
    </div>
  )
}

function LandingCounter({ label }: { label: string }) {
  const [count, setCount] = useState(0)
  return (
    <div className="flex flex-col gap-1.5">
      <label className="text-gray-500 text-[10px] uppercase tracking-wider font-medium">{label}</label>
      <div className="flex items-center gap-2 bg-[#0D1424] border border-[#1E2D45] rounded-xl overflow-hidden">
        <button
          onClick={() => setCount(Math.max(0, count - 1))}
          className="px-3 py-2.5 text-gray-400 hover:text-white hover:bg-[#1E2D45] transition-colors text-lg leading-none"
        >−</button>
        <span className="flex-1 text-white text-sm text-center font-medium">{count}</span>
        <button
          onClick={() => setCount(count + 1)}
          className="px-3 py-2.5 text-gray-400 hover:text-white hover:bg-[#1E2D45] transition-colors text-lg leading-none"
        >+</button>
      </div>
    </div>
  )
}

export default function AddFlightPage() {
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
            <h1 className="text-white text-xl font-bold">New Flight</h1>
            <p className="text-gray-500 text-xs">April 25, 2026</p>
          </div>
        </div>
      </div>

      <div className="px-5 flex flex-col gap-5">
        {/* Date & Aircraft */}
        <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex flex-col gap-4">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Flight Info</p>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-gray-500 text-[10px] uppercase tracking-wider mb-1.5 block">Date</label>
              <input type="date" defaultValue="2026-04-25" className="w-full bg-[#0D1424] border border-[#1E2D45] rounded-xl px-3 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500"/>
            </div>
            <div>
              <label className="text-gray-500 text-[10px] uppercase tracking-wider mb-1.5 block">Aircraft</label>
              <select className="w-full bg-[#0D1424] border border-[#1E2D45] rounded-xl px-3 py-2.5 text-gray-300 text-sm focus:outline-none focus:border-blue-500 appearance-none">
                <option>C172</option>
                <option>PA-31-350</option>
                <option>+ Add new</option>
              </select>
            </div>
          </div>
          <div>
            <label className="text-gray-500 text-[10px] uppercase tracking-wider mb-1.5 block">Tail Number</label>
            <input type="text" placeholder="N1234X" className="w-full bg-[#0D1424] border border-[#1E2D45] rounded-xl px-3 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500 placeholder-gray-700 uppercase"/>
          </div>
        </div>

        {/* Route */}
        <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex flex-col gap-3">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Route</p>
          <div className="flex items-center gap-3">
            <div className="flex-1">
              <label className="text-gray-500 text-[10px] uppercase tracking-wider mb-1.5 block">From</label>
              <input type="text" placeholder="ICAO" maxLength={4} className="w-full bg-[#0D1424] border border-[#1E2D45] rounded-xl px-3 py-2.5 text-white text-sm text-center uppercase font-mono tracking-widest focus:outline-none focus:border-blue-500 placeholder-gray-700"/>
            </div>
            <div className="mt-4 flex-shrink-0">
              <svg width="20" height="20" fill="none" viewBox="0 0 24 24">
                <path d="M5 12h14M13 6l6 6-6 6" stroke="#3B82F6" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </div>
            <div className="flex-1">
              <label className="text-gray-500 text-[10px] uppercase tracking-wider mb-1.5 block">To</label>
              <input type="text" placeholder="ICAO" maxLength={4} className="w-full bg-[#0D1424] border border-[#1E2D45] rounded-xl px-3 py-2.5 text-white text-sm text-center uppercase font-mono tracking-widest focus:outline-none focus:border-blue-500 placeholder-gray-700"/>
            </div>
          </div>
        </div>

        {/* Aircraft Category */}
        <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex flex-col gap-3">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Aircraft Category</p>
          <div className="grid grid-cols-3 gap-2">
            <TimeInput label="SEL" name="sel" />
            <TimeInput label="MEL" name="mel" />
            <TimeInput label="Gnd Trn." name="gt" />
          </div>
        </div>

        {/* Piloting Time */}
        <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex flex-col gap-3">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Piloting Time</p>
          <div className="grid grid-cols-2 gap-2">
            <TimeInput label="PIC" name="pic" />
            <TimeInput label="Dual Rcvd." name="dual" />
          </div>
        </div>

        {/* Conditions of Flight */}
        <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex flex-col gap-3">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Conditions of Flight</p>
          <div className="grid grid-cols-3 gap-2">
            <TimeInput label="Day" name="day" />
            <TimeInput label="Night" name="night" />
            <TimeInput label="X-Country" name="xc" />
            <TimeInput label="Actual Instr." name="actual" />
            <TimeInput label="Sim. Instr." name="sim" />
            <div className="flex flex-col gap-1.5">
              <label className="text-gray-500 text-[10px] uppercase tracking-wider font-medium">Appr.</label>
              <input type="number" min="0" placeholder="0" className="bg-[#0D1424] border border-[#1E2D45] rounded-xl px-3 py-2.5 text-white text-sm text-center focus:outline-none focus:border-blue-500"/>
            </div>
          </div>
        </div>

        {/* Landings */}
        <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex flex-col gap-3">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Landings</p>
          <div className="grid grid-cols-2 gap-3">
            <LandingCounter label="Day" />
            <LandingCounter label="Night" />
          </div>
        </div>

        {/* Total */}
        <div className="bg-[#0D1B35] rounded-2xl p-4 border border-blue-500/20 flex flex-col gap-2">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Total Duration</p>
          <input type="number" step="0.1" placeholder="0.0" className="bg-transparent text-blue-400 text-3xl font-bold focus:outline-none w-full" />
        </div>

        {/* Remarks */}
        <div className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex flex-col gap-2">
          <p className="text-gray-400 text-xs uppercase tracking-wider font-semibold">Remarks / Maneuvers</p>
          <textarea
            rows={3}
            placeholder="Notes, procedures, maneuvers performed..."
            className="bg-transparent text-white text-sm resize-none focus:outline-none placeholder-gray-700 w-full"
          />
        </div>

        {/* Save */}
        <button className="w-full bg-blue-500 text-white font-semibold py-4 rounded-2xl shadow-lg shadow-blue-500/20 hover:bg-blue-400 transition-colors">
          Save Flight
        </button>
      </div>

      <BottomNav />
    </div>
  )
}
