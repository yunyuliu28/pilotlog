'use client'

interface CurrencyRingProps {
  label: string
  daysLeft: number
  total: number
  unit?: string
}

export default function CurrencyRing({ label, daysLeft, total, unit = 'days' }: CurrencyRingProps) {
  const percentage = Math.max(0, Math.min(1, daysLeft / total))
  const radius = 34
  const circumference = 2 * Math.PI * radius
  const strokeDashoffset = circumference * (1 - percentage)
  const expired = daysLeft <= 0

  const color = expired ? '#EF4444' : percentage > 0.3 ? '#10B981' : '#F59E0B'
  const bgText = expired ? 'text-red-400' : percentage > 0.3 ? 'text-emerald-400' : 'text-amber-400'

  return (
    <div className="flex flex-col items-center gap-2">
      <div className="relative w-[88px] h-[88px]">
        <svg className="w-full h-full -rotate-90" viewBox="0 0 88 88">
          <circle cx="44" cy="44" r={radius} fill="none" stroke="#1E2D45" strokeWidth="6" />
          <circle
            cx="44" cy="44" r={radius}
            fill="none"
            stroke={color}
            strokeWidth="6"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={expired ? circumference : strokeDashoffset}
            style={{ transition: 'stroke-dashoffset 0.5s ease' }}
          />
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          {expired ? (
            <span className="text-red-400 text-xs font-bold tracking-wide">EXP</span>
          ) : (
            <>
              <span className={`text-base font-bold ${bgText}`}>{daysLeft}</span>
              <span className="text-gray-500 text-[9px] uppercase tracking-wider">{unit}</span>
            </>
          )}
        </div>
      </div>
      <span className="text-gray-400 text-[11px] font-medium text-center">{label}</span>
    </div>
  )
}
