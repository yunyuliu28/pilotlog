import Link from 'next/link'
import BottomNav from '@/components/BottomNav'
import CurrencyRing from '@/components/CurrencyRing'
import { flights, careerTotals, currencyData } from '@/lib/mockData'

export default function DashboardPage() {
  const recentFlights = flights.slice(-3).reverse()

  return (
    <div className="flex flex-col min-h-screen bg-[#0A0F1E] pb-24">
      {/* Header */}
      <div className="px-5 pt-14 pb-6 bg-gradient-to-b from-[#0D1B35] to-[#0A0F1E]">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-gray-500 text-sm">Good morning,</p>
            <h1 className="text-white text-2xl font-bold mt-0.5">Capt. Smith ✈️</h1>
          </div>
          <Link href="/profile">
            <div className="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center font-bold text-white shadow-lg shadow-blue-500/20">
              JS
            </div>
          </Link>
        </div>

        {/* Total hours pill */}
        <div className="mt-5 flex gap-3">
          <div className="flex-1 bg-[#111827] rounded-2xl px-4 py-3 border border-[#1E2D45]">
            <p className="text-gray-500 text-xs uppercase tracking-wider">Total Hours</p>
            <p className="text-white text-2xl font-bold mt-0.5">{careerTotals.total.toFixed(1)}</p>
          </div>
          <div className="flex-1 bg-[#111827] rounded-2xl px-4 py-3 border border-[#1E2D45]">
            <p className="text-gray-500 text-xs uppercase tracking-wider">PIC</p>
            <p className="text-white text-2xl font-bold mt-0.5">{careerTotals.pic.toFixed(1)}</p>
          </div>
          <div className="flex-1 bg-[#111827] rounded-2xl px-4 py-3 border border-[#1E2D45]">
            <p className="text-gray-500 text-xs uppercase tracking-wider">XC</p>
            <p className="text-white text-2xl font-bold mt-0.5">{careerTotals.xc.toFixed(1)}</p>
          </div>
        </div>
      </div>

      {/* Currency Section */}
      <div className="px-5 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-white font-semibold text-base">Currency Status</h2>
          <span className="text-gray-500 text-xs">1 expired</span>
        </div>
        <div className="bg-[#111827] rounded-2xl p-5 border border-[#1E2D45]">
          <div className="grid grid-cols-4 gap-2">
            {currencyData.map((item) => (
              <CurrencyRing key={item.label} {...item} />
            ))}
          </div>
          <div className="mt-4 pt-4 border-t border-[#1E2D45] flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-red-400" />
            <p className="text-gray-400 text-xs">IFR currency expired — 6 approaches needed</p>
          </div>
        </div>
      </div>

      {/* Recent Flights */}
      <div className="px-5">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-white font-semibold text-base">Recent Flights</h2>
          <Link href="/logbook" className="text-blue-400 text-xs font-medium">View all</Link>
        </div>
        <div className="flex flex-col gap-3">
          {recentFlights.map((flight) => (
            <div key={flight.id} className="bg-[#111827] rounded-2xl p-4 border border-[#1E2D45] flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-[#1A2940] flex items-center justify-center flex-shrink-0">
                <svg width="18" height="18" fill="none" viewBox="0 0 24 24">
                  <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1 3.5 1v-1.5L13 19v-5.5l8 2.5z" fill="#3B82F6"/>
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <span className="text-white text-sm font-semibold">{flight.from}</span>
                  <svg width="12" height="12" fill="none" viewBox="0 0 24 24">
                    <path d="M5 12h14M13 6l6 6-6 6" stroke="#6B7280" strokeWidth="2" strokeLinecap="round"/>
                  </svg>
                  <span className="text-white text-sm font-semibold">{flight.to}</span>
                  <span className="ml-auto text-gray-500 text-xs flex-shrink-0">{flight.date}</span>
                </div>
                <div className="flex items-center gap-2 mt-1">
                  <span className="text-gray-400 text-xs">{flight.aircraft} · {flight.ident}</span>
                  <span className="ml-auto text-blue-400 text-xs font-medium">{flight.total.toFixed(1)} hrs</span>
                </div>
                {flight.remarks && (
                  <p className="text-gray-600 text-xs mt-0.5 truncate">{flight.remarks}</p>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Quick add button */}
      <Link
        href="/add-flight"
        className="mx-5 mt-4 py-4 rounded-2xl border border-dashed border-[#1E2D45] flex items-center justify-center gap-2 text-gray-500 text-sm hover:border-blue-500 hover:text-blue-400 transition-colors"
      >
        <svg width="16" height="16" fill="none" viewBox="0 0 24 24">
          <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2"/>
          <path d="M12 8v8M8 12h8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
        </svg>
        Log new flight
      </Link>

      <BottomNav />
    </div>
  )
}
