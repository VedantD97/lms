import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "@/lib/auth/AuthContext";
import { Button } from "@/components/ui/Button";
import { Input, Label } from "@/components/ui/Field";
import { getErrorMessage } from "@/lib/api/errors";
import { homePathForUser } from "@/lib/auth/roleRoutes";

export function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const user = await login(email, password);
      navigate(homePathForUser(user));
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden px-4 py-10">
      <div
        className="pointer-events-none absolute inset-0 bg-ink"
        style={{
          backgroundImage:
            "radial-gradient(ellipse at 20% 20%, rgb(15 118 110 / 0.45), transparent 45%), radial-gradient(ellipse at 80% 80%, rgb(14 116 144 / 0.3), transparent 40%)",
        }}
      />
      <div className="relative grid w-full max-w-5xl overflow-hidden rounded-3xl border border-white/10 bg-white shadow-2xl lg:grid-cols-2">
        <div className="hidden flex-col justify-between bg-ink p-10 text-white lg:flex">
          <div>
            <div className="flex items-center gap-2">
              <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-brand font-display text-sm font-bold">
                LH
              </span>
              <span className="font-display text-xl font-bold">LearnHub</span>
            </div>
            <h1 className="mt-10 font-display text-3xl font-bold leading-tight tracking-tight">
              Learn without limits
            </h1>
            <p className="mt-3 text-sm text-slate-300">
              Sign in to continue your courses, track progress, and unlock new skills.
            </p>
          </div>
          <p className="text-xs text-slate-400">Enter your email and password to access LearnHub.</p>
        </div>

        <form onSubmit={handleSubmit} className="animate-fade-up p-8 sm:p-10">
          <h2 className="font-display text-2xl font-bold text-ink lg:hidden">Sign in to LearnHub</h2>
          <h2 className="hidden font-display text-2xl font-bold text-ink lg:block">Welcome back</h2>
          <p className="mt-2 text-sm text-slate-600">Use your account credentials to continue.</p>

          <div className="mt-6 space-y-4">
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                autoComplete="username"
                required
              />
            </div>
            <div>
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
                required
              />
            </div>
          </div>

          {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}

          <Button type="submit" className="mt-6 w-full" disabled={loading}>
            {loading ? "Signing in..." : "Sign in"}
          </Button>

          <p className="mt-4 text-center text-sm text-slate-600">
            Don&apos;t have an account?{" "}
            <Link to="/register" className="font-semibold text-brand hover:text-brand-hover">
              Sign up
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}
