import { describe, expect, it } from "vitest";

function notificationLabel(type: string) {
  return type.replace(/_/g, " ");
}

describe("notification helpers", () => {
  it("formats notification type labels", () => {
    expect(notificationLabel("assignment_graded")).toBe("assignment graded");
    expect(notificationLabel("course_completed")).toBe("course completed");
  });
});
