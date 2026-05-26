export interface Flight {
  id: string
  date: string
  aircraft: string
  ident: string
  from: string
  to: string
  sel: number | null
  mel: number | null
  pic: number | null
  dual: number | null
  day: number | null
  night: number | null
  xc: number | null
  actual: number | null
  sim: number | null
  appr: number | null
  ldgDay: number | null
  ldgNight: number | null
  total: number
  remarks: string
}

export const flights: Flight[] = [
  { id: '1', date: '02/22/25', aircraft: 'C172', ident: 'N41QQC', from: 'FAI', to: 'FAI', sel: 4.4, mel: null, pic: 4.4, dual: null, day: 4.3, night: 0.1, xc: null, actual: null, sim: null, appr: null, ldgDay: 1, ldgNight: null, total: 4.4, remarks: 'Moose Spotting Coldfoot' },
  { id: '2', date: '02/23/25', aircraft: 'PA-31-350', ident: 'N234CE', from: 'FAI', to: 'CXF/FAI', sel: null, mel: 2.3, pic: 2.3, dual: null, day: 2.3, night: null, xc: 2.3, actual: null, sim: null, appr: null, ldgDay: 2, ldgNight: null, total: 2.3, remarks: 'NATC Tour Coldfoot' },
  { id: '3', date: '02/25/25', aircraft: 'PA-31-350', ident: 'N234CE', from: 'FAI', to: 'CXF/FAI', sel: null, mel: 2.4, pic: 2.4, dual: null, day: 2.4, night: null, xc: 2.4, actual: null, sim: null, appr: null, ldgDay: 2, ldgNight: null, total: 2.4, remarks: '' },
  { id: '4', date: '02/26/25', aircraft: 'C172', ident: 'N4401L', from: 'FAI', to: 'FAI', sel: 2.5, mel: null, pic: 2.5, dual: null, day: 2.5, night: null, xc: null, actual: null, sim: null, appr: null, ldgDay: 2, ldgNight: null, total: 2.5, remarks: 'Maneuvers' },
  { id: '5', date: '03/06/25', aircraft: 'C172', ident: 'N4401L', from: 'FAI', to: 'MLY/FAI', sel: 3.7, mel: null, pic: 3.7, dual: null, day: 3.7, night: null, xc: 2.6, actual: null, sim: 0.5, appr: 1, ldgDay: 4, ldgNight: null, total: 3.7, remarks: 'Maneuvers / XC' },
  { id: '6', date: '03/07/25', aircraft: 'PA-31-350', ident: 'N5LIVA', from: 'FAI', to: 'CXF/FAI', sel: null, mel: 2.5, pic: 2.5, dual: 2.5, day: 2.5, night: null, xc: 2.5, actual: 1.0, sim: null, appr: null, ldgDay: 2, ldgNight: null, total: 2.5, remarks: 'JA' },
  { id: '7', date: '03/09/25', aircraft: 'C172', ident: 'N4166L', from: 'FAI', to: 'CXF/FAI', sel: 4.2, mel: null, pic: 4.2, dual: null, day: 4.2, night: null, xc: 4.2, actual: null, sim: null, appr: null, ldgDay: 2, ldgNight: null, total: 4.2, remarks: 'C172 CXF' },
]

export const pageTotals = {
  sel: 14.8, mel: 7.2, pic: 22.0, dual: 2.5,
  day: 21.9, night: 0.1, xc: 14.0, actual: 1.0, sim: 0.5, appr: 1,
  ldgDay: 15, ldgNight: 1, total: 22.0,
}

export const careerTotals = {
  sel: 533.2, mel: 362.8, gt: 29.6, pic: 628.1, dual: 220.9,
  day: 861.9, night: 106.5, xc: 688.2, actual: 18.1, sim: 67.0, appr: 90,
  ldgDay: 195, ldgNight: 117, total: 939.6,
}

export const currencyData = [
  { label: 'Day VFR', daysLeft: 45, total: 90, unit: 'days' },
  { label: 'Night VFR', daysLeft: 12, total: 90, unit: 'days' },
  { label: 'IFR', daysLeft: 0, total: 180, unit: 'days' },
  { label: 'Flight Review', daysLeft: 8, total: 24, unit: 'mo' },
]
