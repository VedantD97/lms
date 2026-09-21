import type { User } from "@/lib/api/types/course";

const ROLE_HOME: Record<string, string> = {
  super_admin: "/admin/dashboard",
  admin: "/admin/dashboard",
  instructor: "/instructor/dashboard",
  student: "/student/dashboard",
};

export function homePathForUser(user: Pick<User, "roles" | "highest_role">): string {
  if (user.highest_role && ROLE_HOME[user.highest_role]) {
    return ROLE_HOME[user.highest_role];
  }

  if (user.roles.includes("super_admin") || user.roles.includes("admin")) {
    return ROLE_HOME.admin;
  }
  if (user.roles.includes("instructor")) {
    return ROLE_HOME.instructor;
  }

  return ROLE_HOME.student;
}

export function userHasAnyRole(user: Pick<User, "roles">, roles: string[]): boolean {
  return roles.some((role) => user.roles.includes(role));
}

export function isAdminUser(user: Pick<User, "roles"> | null | undefined): boolean {
  return Boolean(user && userHasAnyRole(user, ["admin", "super_admin"]));
}

export function isInstructorUser(user: Pick<User, "roles"> | null | undefined): boolean {
  return Boolean(user && userHasAnyRole(user, ["instructor"]));
}

export function isStudentUser(user: Pick<User, "roles"> | null | undefined): boolean {
  return Boolean(user && userHasAnyRole(user, ["student"]));
}
