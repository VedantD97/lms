import { describe, expect, it } from "vitest";
import { formatProgressSummary, studentName } from "@/features/instructor/dashboard/instructorDashboardHelpers";

describe("instructor dashboard helpers", () => {
  it("formats progress summary", () => {
    expect(formatProgressSummary({ completed_items: 3, total_items: 5 })).toBe("3/5 items complete");
  });

  it("formats student name", () => {
    expect(studentName({ first_name: "Ada", last_name: "Lovelace" })).toBe("Ada Lovelace");
  });
});
