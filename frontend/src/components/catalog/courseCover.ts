const COVER_PALETTES = [
  ["#0f766e", "#134e4a"],
  ["#0e7490", "#155e75"],
  ["#1d4ed8", "#1e3a8a"],
  ["#b45309", "#78350f"],
  ["#be123c", "#881337"],
  ["#4338ca", "#312e81"],
  ["#047857", "#064e3b"],
  ["#0369a1", "#0c4a6e"],
] as const;

export function coverPaletteFor(seed: string): { from: string; to: string } {
  let hash = 0;
  for (let i = 0; i < seed.length; i += 1) {
    hash = (hash * 31 + seed.charCodeAt(i)) >>> 0;
  }
  const [from, to] = COVER_PALETTES[hash % COVER_PALETTES.length];
  return { from, to };
}

export function coverInitials(title: string): string {
  const words = title.trim().split(/\s+/).filter(Boolean);
  if (!words.length) return "LH";
  if (words.length === 1) return words[0].slice(0, 2).toUpperCase();
  return `${words[0][0] ?? ""}${words[1][0] ?? ""}`.toUpperCase();
}
