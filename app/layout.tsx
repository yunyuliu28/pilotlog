import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'PilotLog',
  description: 'Your digital flight logbook',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-[#060C18] flex items-start justify-center">
        <div className="w-full max-w-[430px] min-h-screen bg-[#0A0F1E] relative flex flex-col shadow-2xl">
          {children}
        </div>
      </body>
    </html>
  )
}
