export function formatAverageProgress(value: number) {
  return `${value.toFixed(0)}% avg progress`;
}

export function pendingActionsLabel(pending: { quizzes: number; assignments: number }) {
  const parts: string[] = [];
  if (pending.quizzes > 0) parts.push(`${pending.quizzes} quiz${pending.quizzes === 1 ? "" : "zes"}`);
  if (pending.assignments > 0) parts.push(`${pending.assignments} assignment${pending.assignments === 1 ? "" : "s"}`);
  return parts.length ? parts.join(" · ") : "All caught up";
}
