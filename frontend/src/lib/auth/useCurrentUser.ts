import { useQueryClient } from "@tanstack/react-query";
import { useAuth } from "@/lib/auth/AuthContext";
import type { User } from "@/lib/api/types/course";

export function useCurrentUser(): User | null {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return queryClient.getQueryData<User>(["auth", "me"]) ?? user;
}
