import { describe, expect, it } from "vitest";

function formatProgressLabel(percent: number, status: string) {
  return `${percent}% · ${status.replace("_", " ")}`;
}

function progressDetail(enrollment: {
  progress_summary?: {
    completed_items: number;
    total_items: number;
    passed_quizzes: number;
    total_quizzes: number;
  };
  progress_percent: number;
}) {
  const summary = enrollment.progress_summary;
  if (!summary) return `${enrollment.progress_percent}% complete`;

  const items = `${summary.completed_items}/${summary.total_items} items`;
  if (summary.total_quizzes > 0 && summary.passed_quizzes < summary.total_quizzes) {
    return `${items} · ${summary.passed_quizzes}/${summary.total_quizzes} quizzes passed`;
  }

  return items;
}

describe("learning helpers", () => {
  it("formats progress label", () => {
    expect(formatProgressLabel(50, "in_progress")).toBe("50% · in progress");
  });

  it("handles completed status", () => {
    expect(formatProgressLabel(100, "completed")).toBe("100% · completed");
  });

  it("shows quiz progress when quizzes are pending", () => {
    expect(
      progressDetail({
        progress_percent: 50,
        progress_summary: {
          completed_items: 1,
          total_items: 2,
          passed_quizzes: 0,
          total_quizzes: 1,
        },
      }),
    ).toBe("1/2 items · 0/1 quizzes passed");
  });
});
