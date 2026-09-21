import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { RegisterPage } from "@/pages/auth/RegisterPage";

const registerMock = vi.fn();
const navigateMock = vi.fn();

vi.mock("react-router-dom", async () => {
  const actual = await vi.importActual<typeof import("react-router-dom")>("react-router-dom");
  return {
    ...actual,
    useNavigate: () => navigateMock,
  };
});

vi.mock("@/lib/auth/AuthContext", () => ({
  useAuth: () => ({
    register: registerMock,
    login: vi.fn(),
    logout: vi.fn(),
    user: null,
    isLoading: false,
  }),
}));

describe("RegisterPage", () => {
  it("creates an account and redirects to the student dashboard", async () => {
    registerMock.mockResolvedValue({ roles: ["student"], email: "new@example.com" });

    render(
      <MemoryRouter>
        <RegisterPage />
      </MemoryRouter>,
    );

    fireEvent.change(screen.getByLabelText("First name"), { target: { value: "New" } });
    fireEvent.change(screen.getByLabelText("Last name"), { target: { value: "Student" } });
    fireEvent.change(screen.getByLabelText("Email"), { target: { value: "new@example.com" } });
    fireEvent.change(screen.getByLabelText("Password"), { target: { value: "password123" } });
    fireEvent.change(screen.getByLabelText("Confirm password"), { target: { value: "password123" } });
    fireEvent.click(screen.getByRole("button", { name: "Sign up" }));

    await waitFor(() => {
      expect(registerMock).toHaveBeenCalledWith({
        first_name: "New",
        last_name: "Student",
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123",
      });
      expect(navigateMock).toHaveBeenCalledWith("/student/dashboard");
    });
  });

  it("shows an error when passwords do not match", async () => {
    render(
      <MemoryRouter>
        <RegisterPage />
      </MemoryRouter>,
    );

    fireEvent.change(screen.getByLabelText("First name"), { target: { value: "New" } });
    fireEvent.change(screen.getByLabelText("Last name"), { target: { value: "Student" } });
    fireEvent.change(screen.getByLabelText("Email"), { target: { value: "new@example.com" } });
    fireEvent.change(screen.getByLabelText("Password"), { target: { value: "password123" } });
    fireEvent.change(screen.getByLabelText("Confirm password"), { target: { value: "different" } });
    fireEvent.click(screen.getByRole("button", { name: "Sign up" }));

    expect(await screen.findByText("Password confirmation doesn't match Password")).toBeInTheDocument();
    expect(registerMock).not.toHaveBeenCalled();
  });
});
