import { Navigate, Outlet } from "react-router-dom";
import { homePathForUser, userHasAnyRole } from "@/lib/auth/roleRoutes";
import { useCurrentUser } from "@/lib/auth/useCurrentUser";

interface RoleGuardProps {
  roles: string[];
}

export function RoleGuard({ roles }: RoleGuardProps) {
  const user = useCurrentUser();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (!userHasAnyRole(user, roles)) {
    return <Navigate to={homePathForUser(user)} replace />;
  }

  return <Outlet />;
}
