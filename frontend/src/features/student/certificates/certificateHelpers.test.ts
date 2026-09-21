import { describe, expect, it } from "vitest";

function certificateLabel(number: string) {
  return `Certificate ${number}`;
}

describe("certificate helpers", () => {
  it("formats certificate label", () => {
    expect(certificateLabel("LMS-20260905-AB12CD34")).toBe("Certificate LMS-20260905-AB12CD34");
  });
});
