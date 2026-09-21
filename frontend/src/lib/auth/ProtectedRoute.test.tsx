import { describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import { ProtectedRoute } from "@/lib/auth/ProtectedRoute";

vi.mock("@/lib/auth/AuthContext", () => ({
  useAuth: () => ({
    login: vi.fn(),
    logout: vi.fn(),
    user: null,
    isLoading: false,
  }),
}));

describe("ProtectedRoute", () => {
  it("redirects unauthenticated users to login", async () => {
    render(
      <MemoryRouter initialEntries={["/student/dashboard"]}>
        <Routes>
          <Route element={<ProtectedRoute />}>
            <Route path="/student/dashboard" element={<div>Student home</div>} />
          </Route>
          <Route path="/login" element={<div>Login screen</div>} />
        </Routes>
      </MemoryRouter>,
    );

    expect(await screen.findByText("Login screen")).toBeInTheDocument();
  });
});
