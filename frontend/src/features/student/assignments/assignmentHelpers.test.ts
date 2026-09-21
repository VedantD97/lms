import { describe, expect, it } from "vitest";

function assignmentStatusLabel(passed?: boolean, submissionStatus?: string | null) {
  if (passed) return "Passed";
  if (submissionStatus === "submitted") return "Submitted";
  if (submissionStatus === "graded") return "Graded";
  return "Required";
}

describe("assignment helpers", () => {
  it("shows passed status", () => {
    expect(assignmentStatusLabel(true, "graded")).toBe("Passed");
  });

  it("shows submitted status", () => {
    expect(assignmentStatusLabel(false, "submitted")).toBe("Submitted");
  });
});
