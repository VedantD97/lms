import { describe, expect, it } from "vitest";
import { formatAverageProgress, pendingActionsLabel } from "@/features/student/dashboard/studentDashboardHelpers";

describe("student dashboard helpers", () => {
  it("formats average progress", () => {
    expect(formatAverageProgress(42.5)).toBe("43% avg progress");
  });

  it("formats pending actions", () => {
    expect(pendingActionsLabel({ quizzes: 2, assignments: 1 })).toBe("2 quizzes · 1 assignment");
    expect(pendingActionsLabel({ quizzes: 0, assignments: 0 })).toBe("All caught up");
  });
});
