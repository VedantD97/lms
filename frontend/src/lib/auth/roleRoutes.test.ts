import { describe, expect, it } from "vitest";
import { homePathForUser, userHasAnyRole } from "@/lib/auth/roleRoutes";

describe("roleRoutes", () => {
  it("uses highest_role for the home path", () => {
    expect(
      homePathForUser({
        roles: ["student", "instructor"],
        highest_role: "student",
      }),
    ).toBe("/student/dashboard");
  });

  it("falls back to role priority when highest_role is missing", () => {
    expect(homePathForUser({ roles: ["instructor"] })).toBe("/instructor/dashboard");
    expect(homePathForUser({ roles: ["student"] })).toBe("/student/dashboard");
  });

  it("checks allowed roles", () => {
    expect(userHasAnyRole({ roles: ["student"] }, ["student"])).toBe(true);
    expect(userHasAnyRole({ roles: ["student"] }, ["admin"])).toBe(false);
  });
});
