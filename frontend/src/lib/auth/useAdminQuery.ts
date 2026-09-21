import { useQuery } from "@tanstack/react-query";
import { isAdminUser } from "@/lib/auth/roleRoutes";
import { useCurrentUser } from "@/lib/auth/useCurrentUser";

export function useAdminQuery<TData>(queryKey: unknown[], queryFn: () => Promise<TData>) {
  const user = useCurrentUser();

  return useQuery({
    queryKey,
    queryFn,
    enabled: isAdminUser(user),
  });
}
