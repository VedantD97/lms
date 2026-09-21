export function formatPercent(value: number) {
  return `${value.toFixed(1)}%`;
}

export function formatCountLabel(label: string, value: number) {
  return `${label}: ${value.toLocaleString()}`;
}
