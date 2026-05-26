'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'

const navItems = [
  {
    href: '/dashboard',
    label: 'Home',
    icon: (active: boolean) => (
      <svg width="22" height="22" fill="none" viewBox="0 0 24 24">
        <path d="M3 12L12 3l9 9" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        <path d="M9 21V12h6v9" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        <path d="M5 10v11h14V10" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    ),
  },
  {
    href: '/logbook',
    label: 'Logbook',
    icon: (active: boolean) => (
      <svg width="22" height="22" fill="none" viewBox="0 0 24 24">
        <rect x="3" y="3" width="18" height="18" rx="2" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2"/>
        <path d="M7 8h10M7 12h10M7 16h6" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2" strokeLinecap="round"/>
      </svg>
    ),
  },
  {
    href: '/scan',
    label: 'Scan',
    icon: (_active: boolean) => (
      <svg width="26" height="26" fill="none" viewBox="0 0 24 24">
        <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
        <circle cx="12" cy="13" r="4" stroke="white" strokeWidth="2"/>
      </svg>
    ),
    isAction: true,
  },
  {
    href: '/add-flight',
    label: 'Add',
    icon: (active: boolean) => (
      <svg width="22" height="22" fill="none" viewBox="0 0 24 24">
        <circle cx="12" cy="12" r="9" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2"/>
        <path d="M12 8v8M8 12h8" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2" strokeLinecap="round"/>
      </svg>
    ),
  },
  {
    href: '/profile',
    label: 'Profile',
    icon: (active: boolean) => (
      <svg width="22" height="22" fill="none" viewBox="0 0 24 24">
        <circle cx="12" cy="8" r="4" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2"/>
        <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke={active ? '#3B82F6' : '#6B7280'} strokeWidth="2" strokeLinecap="round"/>
      </svg>
    ),
  },
]

export default function BottomNav() {
  const pathname = usePathname()

  return (
    <div className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] bg-[#0D1424] border-t border-[#1E2D45] z-50">
      <div className="flex items-center justify-around px-2 pb-safe">
        {navItems.map((item) => {
          const active = pathname === item.href

          if (item.isAction) {
            return (
              <Link key={item.href} href={item.href} className="flex flex-col items-center -mt-6">
                <div className="w-14 h-14 rounded-full bg-blue-500 flex items-center justify-center shadow-lg shadow-blue-500/30">
                  {item.icon(true)}
                </div>
                <span className="text-[10px] text-gray-500 mt-1">{item.label}</span>
              </Link>
            )
          }

          return (
            <Link key={item.href} href={item.href} className="flex flex-col items-center gap-1 py-3 px-3">
              {item.icon(active)}
              <span className={`text-[10px] font-medium ${active ? 'text-blue-400' : 'text-gray-500'}`}>
                {item.label}
              </span>
            </Link>
          )
        })}
      </div>
    </div>
  )
}
