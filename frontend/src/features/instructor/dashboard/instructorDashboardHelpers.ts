export function formatProgressSummary(summary?: {
  completed_items: number;
  total_items: number;
}) {
  if (!summary || summary.total_items === 0) return "No required items";
  return `${summary.completed_items}/${summary.total_items} items complete`;
}

export function studentName(student: { first_name: string; last_name: string }) {
  return `${student.first_name} ${student.last_name}`.trim();
}
