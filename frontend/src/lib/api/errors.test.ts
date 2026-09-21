import { describe, expect, it } from "vitest";
import { ApiRequestError, getErrorMessage } from "@/lib/api/errors";

describe("api errors", () => {
  it("formats rate limit errors clearly", () => {
    const error = new ApiRequestError(429, {
      code: "rate_limit_exceeded",
      message: "Too many requests. Please try again later.",
    });

    expect(getErrorMessage(error)).toBe("Too many attempts. Please wait a few minutes and try again.");
  });
});
