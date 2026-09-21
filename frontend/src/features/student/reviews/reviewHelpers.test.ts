import { describe, expect, it } from "vitest";
import { formatRating, starSymbols } from "@/features/student/reviews/reviewHelpers";

describe("review helpers", () => {
  it("formats rating with review count", () => {
    expect(formatRating(4.5, 2)).toBe("4.5 (2 reviews)");
    expect(formatRating(5, 1)).toBe("5.0 (1 review)");
  });

  it("handles empty ratings", () => {
    expect(formatRating(null, 0)).toBe("No reviews yet");
  });

  it("renders star symbols", () => {
    expect(starSymbols(4)).toBe("★★★★☆");
  });
});
