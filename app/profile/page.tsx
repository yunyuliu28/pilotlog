import Link from 'next/link'
import BottomNav from '@/components/BottomNav'
import { careerTotals } from '@/lib/mockData'

const stats = [
  { label: 'Total Hours', value: careerTotals.total.toFixed(1) },
  { label: 'PIC', value: careerTotals.pic.toFixed(1) },
  { label: 'Night', value: careerTotals.night.toFixed(1) },
  { label: 'IFR', value: careerTotals.actual.toFixed(1) },
  { label: 'X-Country', value: careerTotals.xc.toFixed(1) },
  { label: 'Dual Rcvd.', value: careerTotals.dual.toFixed(1) },
]

const settingsItems = [
  { label: 'Aircraft', icon: '✈️', sub: '3 aircraft logged' },
  { label: 'Notifications', icon: '🔔', sub: 'Currency alerts enabled' },
  { label: 'Export Logbook', icon: '📤', sub: 'CSV or PDF' },
  { label: 'Units', icon: '⏱', sub: 'Decimal hours' },
  { label: 'Backup & Sync', icon: '☁️', sub: 'Last synced just now' },
]

export default function ProfilePage() {
  return (
    <div className="flex flex-col min-h-screen bg-[#0A0F1E] pb-28">
      {/* Header */}
      <div className="px-5 pt-14 pb-6 bg-gradient-to-b from-[#0D1B35] to-[#0A0F1E]">
        <div className="flex items-center justify-between mb-1">
          <h1 className="text-white text-2xl font-bold">Profile</h1>
          <button className="text-blue-400 text-sm font-medium">Edit</button>
        </div>
      </div>

      {/* Pilot card */}
      <div className="mx-5 bg-gradient-to-br from-[#1a3a6e] to-[#0D1B35] rounded-3xl p-5 border border-blue-500/20 mb-5">
        <div className="flex items-center gap-4 mb-4">
          <div className="w-16 h-16 rounded-2xl bg-blue-500 flex items-center justify-center text-white text-2xl font-bold shadow-lg shadow-blue-500/20">
            JS
          </div>
          <div>
            <h2 className="text-white text-lg font-bold">John Smith</h2>
            <p className="text-blue-300 text-sm">Commercial Pilot · ASEL</p>
            <p className="text-gray-500 text-xs mt-0.5">Cert #: 4182930-A</p>
          </div>
        </div>
        <div className="flex items-center gap-2 text-xs text-gray-400">
          <svg width="12" height="12" fill="none" viewBox="0 0 24 24">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z" stroke="#60A5FA" strokeWidth="2"/>
            <circle cx="12" cy="10" r="3" stroke="#60A5FA" strokeWidth="2"/>
          </svg>
          Fairbanks, AK · PAFA
        </div>
      </div>

      {/* Stats grid */}
      <div className="mx-5 mb-5">
        <p className="text-gray-500 text-xs uppercase tracking-wider font-semibold mb-3">Career Totals</p>
        <div className="grid grid-cols-3 gap-2">
          {stats.map((s) => (
            <div key={s.label} className="bg-[#111827] border border-[#1E2D45] rounded-2xl p-3 flex flex-col items-center">
              <span className="text-white text-lg font-bold">{s.value}</span>
              <span className="text-gray-500 text-[10px] uppercase tracking-wide mt-0.5">{s.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Certificates */}
      <div className="mx-5 mb-5">
        <p className="text-gray-500 text-xs uppercase tracking-wider font-semibold mb-3">Certificates & Ratings</p>
        <div className="bg-[#111827] border border-[#1E2D45] rounded-2xl overflow-hidden">
          {[
            { name: 'Commercial Pilot', rating: 'ASEL', expires: 'No expiry' },
            { name: 'Instrument Rating', rating: 'Airplane', expires: 'No expiry' },
            { name: 'Flight Review', rating: 'BFR', expires: 'Mar 2027' },
            { name: 'Medical Certificate', rating: 'Class 2', expires: 'Oct 2026' },
          ].map((cert, i, arr) => (
            <div key={cert.name} className={`flex items-center justify-between px-4 py-3 ${i < arr.length - 1 ? 'border-b border-[#1E2D45]' : ''}`}>
              <div>
                <p className="text-white text-sm font-medium">{cert.name}</p>
                <p className="text-gray-500 text-xs">{cert.rating}</p>
              </div>
              <span className={`text-xs font-medium ${cert.expires.includes('No') ? 'text-gray-500' : 'text-emerald-400'}`}>
                {cert.expires}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Settings */}
      <div className="mx-5 mb-5">
        <p className="text-gray-500 text-xs uppercase tracking-wider font-semibold mb-3">Settings</p>
        <div className="bg-[#111827] border border-[#1E2D45] rounded-2xl overflow-hidden">
          {settingsItems.map((item, i, arr) => (
            <button key={item.label} className={`w-full flex items-center justify-between px-4 py-3.5 hover:bg-[#1A2235] transition-colors ${i < arr.length - 1 ? 'border-b border-[#1E2D45]' : ''}`}>
              <div className="flex items-center gap-3">
                <span className="text-base">{item.icon}</span>
                <div className="text-left">
                  <p className="text-white text-sm font-medium">{item.label}</p>
                  <p className="text-gray-500 text-xs">{item.sub}</p>
                </div>
              </div>
              <svg width="14" height="14" fill="none" viewBox="0 0 24 24">
                <path d="M9 18l6-6-6-6" stroke="#4B5563" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </button>
          ))}
        </div>
      </div>

      {/* Sign out */}
      <div className="mx-5">
        <Link href="/login" className="w-full block text-center py-3.5 rounded-2xl border border-red-500/20 text-red-400 text-sm font-medium hover:bg-red-500/5 transition-colors">
          Sign Out
        </Link>
      </div>

      <BottomNav />
    </div>
  )
}
