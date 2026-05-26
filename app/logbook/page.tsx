import BottomNav from '@/components/BottomNav'
import { flights, pageTotals, careerTotals } from '@/lib/mockData'

const cols = [
  { key: 'date', label: 'Date', width: 'w-20' },
  { key: 'aircraft', label: 'A/C', width: 'w-24' },
  { key: 'route', label: 'Route', width: 'w-24' },
  { key: 'sel', label: 'SEL', width: 'w-14' },
  { key: 'mel', label: 'MEL', width: 'w-14' },
  { key: 'pic', label: 'PIC', width: 'w-14' },
  { key: 'dual', label: 'Dual', width: 'w-14' },
  { key: 'day', label: 'Day', width: 'w-14' },
  { key: 'night', label: 'Night', width: 'w-14' },
  { key: 'xc', label: 'X-C', width: 'w-14' },
  { key: 'actual', label: 'Act.', width: 'w-14' },
  { key: 'sim', label: 'Sim.', width: 'w-14' },
  { key: 'appr', label: 'Appr', width: 'w-12' },
  { key: 'ldgDay', label: 'Ldg D', width: 'w-14' },
  { key: 'ldgNight', label: 'Ldg N', width: 'w-14' },
  { key: 'total', label: 'Total', width: 'w-14' },
]

function Cell({ value, className = '' }: { value: string | number | null, className?: string }) {
  return (
    <td className={`px-2 py-2.5 text-center text-xs whitespace-nowrap ${className}`}>
      {value ?? <span className="text-gray-700">—</span>}
    </td>
  )
}

export default function LogbookPage() {
  return (
    <div className="flex flex-col min-h-screen bg-[#0A0F1E] pb-24">
      {/* Header */}
      <div className="px-5 pt-14 pb-4 bg-gradient-to-b from-[#0D1B35] to-[#0A0F1E]">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-white text-2xl font-bold">Logbook</h1>
            <p className="text-gray-500 text-sm mt-0.5">939.6 total hours · 7 entries shown</p>
          </div>
          <button className="w-9 h-9 rounded-xl bg-[#111827] border border-[#1E2D45] flex items-center justify-center">
            <svg width="16" height="16" fill="none" viewBox="0 0 24 24">
              <path d="M4 6h16M7 12h10M10 18h4" stroke="#9CA3AF" strokeWidth="2" strokeLinecap="round"/>
            </svg>
          </button>
        </div>

        {/* Year filter */}
        <div className="flex gap-2 mt-4">
          {['All', '2025', '2024', '2023'].map((y) => (
            <button
              key={y}
              className={`px-4 py-1.5 rounded-full text-xs font-semibold transition-colors ${
                y === '2025' ? 'bg-blue-500 text-white' : 'bg-[#111827] text-gray-400 border border-[#1E2D45]'
              }`}
            >
              {y}
            </button>
          ))}
        </div>
      </div>

      {/* Summary pills */}
      <div className="px-5 mb-4 flex gap-2 overflow-x-auto pb-1">
        {[
          { label: 'SEL', value: careerTotals.sel },
          { label: 'MEL', value: careerTotals.mel },
          { label: 'Night', value: careerTotals.night },
          { label: 'IFR', value: careerTotals.actual },
        ].map((s) => (
          <div key={s.label} className="flex-shrink-0 bg-[#111827] border border-[#1E2D45] rounded-xl px-3 py-2 flex flex-col items-center min-w-[60px]">
            <span className="text-blue-400 text-sm font-bold">{s.value}</span>
            <span className="text-gray-600 text-[10px] uppercase">{s.label}</span>
          </div>
        ))}
      </div>

      {/* Table */}
      <div className="mx-5 rounded-2xl overflow-hidden border border-[#1E2D45] overflow-x-auto">
        <table className="min-w-full border-collapse">
          {/* Header */}
          <thead>
            <tr className="bg-[#0D1424]">
              {cols.map((col) => (
                <th
                  key={col.key}
                  className={`${col.width} px-2 py-2.5 text-center text-[10px] uppercase tracking-wider text-gray-500 font-semibold whitespace-nowrap border-b border-[#1E2D45]`}
                >
                  {col.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {flights.map((f, i) => (
              <tr
                key={f.id}
                className={`border-b border-[#1A2235] hover:bg-[#141E32] transition-colors cursor-pointer ${i % 2 === 0 ? 'bg-[#111827]' : 'bg-[#0F1A2C]'}`}
              >
                <Cell value={f.date} className="text-gray-300" />
                <Cell value={`${f.aircraft}`} className="text-gray-300 font-medium" />
                <Cell value={`${f.from}→${f.to.split('/')[0]}`} className="text-gray-300" />
                <Cell value={f.sel?.toFixed(1) ?? null} className="text-white" />
                <Cell value={f.mel?.toFixed(1) ?? null} className="text-white" />
                <Cell value={f.pic?.toFixed(1) ?? null} className="text-emerald-400 font-medium" />
                <Cell value={f.dual?.toFixed(1) ?? null} className="text-amber-400" />
                <Cell value={f.day?.toFixed(1) ?? null} className="text-gray-300" />
                <Cell value={f.night?.toFixed(1) ?? null} className="text-blue-300" />
                <Cell value={f.xc?.toFixed(1) ?? null} className="text-gray-300" />
                <Cell value={f.actual?.toFixed(1) ?? null} className="text-gray-300" />
                <Cell value={f.sim?.toFixed(1) ?? null} className="text-gray-300" />
                <Cell value={f.appr ?? null} className="text-gray-300" />
                <Cell value={f.ldgDay ?? null} className="text-gray-300" />
                <Cell value={f.ldgNight ?? null} className="text-gray-300" />
                <Cell value={f.total.toFixed(1)} className="text-white font-bold" />
              </tr>
            ))}

            {/* Page Total */}
            <tr className="bg-[#0D1B35] border-t-2 border-blue-500/30">
              <td colSpan={3} className="px-3 py-2.5 text-[10px] uppercase tracking-wider text-blue-400 font-bold whitespace-nowrap">
                Page Total
              </td>
              <Cell value={pageTotals.sel.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.mel.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.pic.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.dual.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.day.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.night.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.xc.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.actual.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.sim.toFixed(1)} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.appr} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.ldgDay} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.ldgNight} className="text-blue-300 font-bold" />
              <Cell value={pageTotals.total.toFixed(1)} className="text-blue-300 font-bold" />
            </tr>

            {/* Career Total */}
            <tr className="bg-[#0D1B35]">
              <td colSpan={3} className="px-3 py-2.5 text-[10px] uppercase tracking-wider text-emerald-400 font-bold whitespace-nowrap">
                Total to Date
              </td>
              <Cell value={careerTotals.sel.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.mel.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.pic.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.dual.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.day.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.night.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.xc.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.actual.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.sim.toFixed(1)} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.appr} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.ldgDay} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.ldgNight} className="text-emerald-400 font-bold" />
              <Cell value={careerTotals.total.toFixed(1)} className="text-emerald-400 font-bold" />
            </tr>
          </tbody>
        </table>
      </div>

      <p className="text-center text-gray-700 text-xs mt-3">Scroll horizontally to see all columns</p>

      <BottomNav />
    </div>
  )
}
