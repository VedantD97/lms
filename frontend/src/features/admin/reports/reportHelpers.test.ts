import { describe, expect, it } from "vitest";
import { formatCountLabel, formatPercent } from "@/features/admin/reports/reportHelpers";

describe("report helpers", () => {
  it("formats percentages", () => {
    expect(formatPercent(42.567)).toBe("42.6%");
  });

  it("formats count labels", () => {
    expect(formatCountLabel("Students", 1200)).toBe("Students: 1,200");
  });
});
