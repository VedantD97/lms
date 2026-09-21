import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import {
  fetchCurrentUser,
  loginRequest,
  logoutRequest,
  refreshSessionRequest,
  registerRequest,
} from "@/features/auth/api/authApi";
import type { User } from "@/lib/api/types/course";
import { getAccessToken, setAccessToken } from "@/lib/api/client";

interface AuthContextValue {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<User>;
  register: (payload: {
    email: string;
    password: string;
    password_confirmation: string;
    first_name: string;
    last_name: string;
  }) => Promise<User>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);
const AUTH_ME_KEY = ["auth", "me"] as const;

function resetNonAuthQueries(queryClient: ReturnType<typeof useQueryClient>) {
  queryClient.removeQueries({ predicate: (query) => query.queryKey[0] !== "auth" });
}

async function replaceAuthUser(
  queryClient: ReturnType<typeof useQueryClient>,
  user: User,
) {
  await queryClient.cancelQueries({ queryKey: ["auth"] });
  queryClient.setQueryData([...AUTH_ME_KEY], user);
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient();
  const [bootstrapped, setBootstrapped] = useState(false);

  const { data: user, isLoading } = useQuery({
    queryKey: AUTH_ME_KEY,
    queryFn: fetchCurrentUser,
    enabled: bootstrapped && Boolean(getAccessToken()),
    retry: false,
    staleTime: 60_000,
  });

  useEffect(() => {
    let cancelled = false;

    async function bootstrap() {
      if (!getAccessToken()) {
        const session = await refreshSessionRequest();
        if (!cancelled && session?.user) {
          queryClient.setQueryData([...AUTH_ME_KEY], session.user);
        }
      }
      if (!cancelled) setBootstrapped(true);
    }

    void bootstrap();
    return () => {
      cancelled = true;
    };
  }, [queryClient]);

  const value = useMemo<AuthContextValue>(
    () => ({
      user: user ?? null,
      isLoading: !bootstrapped || (isLoading && !user),
      login: async (email, password) => {
        await queryClient.cancelQueries({ queryKey: ["auth"] });
        queryClient.removeQueries({ queryKey: AUTH_ME_KEY });
        resetNonAuthQueries(queryClient);

        const session = await loginRequest(email, password);
        await replaceAuthUser(queryClient, session.user);

        // Confirm identity from /auth/me with the new token (drops any stale race).
        const confirmed = await queryClient.fetchQuery({
          queryKey: AUTH_ME_KEY,
          queryFn: fetchCurrentUser,
        });
        return confirmed;
      },
      register: async (payload) => {
        await queryClient.cancelQueries({ queryKey: ["auth"] });
        queryClient.removeQueries({ queryKey: AUTH_ME_KEY });
        resetNonAuthQueries(queryClient);

        await registerRequest(payload);
        const session = await loginRequest(payload.email, payload.password);
        await replaceAuthUser(queryClient, session.user);

        const confirmed = await queryClient.fetchQuery({
          queryKey: AUTH_ME_KEY,
          queryFn: fetchCurrentUser,
        });
        return confirmed;
      },
      logout: async () => {
        await queryClient.cancelQueries({ queryKey: ["auth"] });
        try {
          await logoutRequest();
        } finally {
          setAccessToken(null);
          queryClient.clear();
        }
      },
    }),
    [user, bootstrapped, isLoading, queryClient],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
}
