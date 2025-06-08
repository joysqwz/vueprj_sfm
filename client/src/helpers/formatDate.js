export function formatDate(isoDateStr) {
  const [year, month, day] = isoDateStr.split('-')
  return `${day}.${month}.${year}`
}
