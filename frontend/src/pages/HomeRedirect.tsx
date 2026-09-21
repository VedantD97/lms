import { Navigate } from "react-router-dom";
import { useAuth } from "@/lib/auth/AuthContext";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { homePathForUser } from "@/lib/auth/roleRoutes";
import { useCurrentUser } from "@/lib/auth/useCurrentUser";

export function HomeRedirect() {
  const { isLoading } = useAuth();
  const user = useCurrentUser();

  if (isLoading) return <LoadingSpinner label="Loading..." />;

  if (!user) return <Navigate to="/login" replace />;

  return <Navigate to={homePathForUser(user)} replace />;
}
