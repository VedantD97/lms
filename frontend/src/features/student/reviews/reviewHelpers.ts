export function formatRating(rating: number | null | undefined, reviewCount?: number) {
  if (rating == null || !reviewCount) return "No reviews yet";
  return `${rating.toFixed(1)} (${reviewCount} review${reviewCount === 1 ? "" : "s"})`;
}

export function starSymbols(rating: number) {
  const clamped = Math.max(1, Math.min(5, Math.round(rating)));
  return "★".repeat(clamped) + "☆".repeat(5 - clamped);
}
