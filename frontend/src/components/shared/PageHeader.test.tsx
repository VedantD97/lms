import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { EmptyState } from "@/components/feedback/EmptyState";
import { StatusBadge } from "@/components/shared/PageHeader";

function renderWithProviders(ui: React.ReactElement) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>{ui}</MemoryRouter>
    </QueryClientProvider>,
  );
}

describe("EmptyState", () => {
  it("renders title and description", () => {
    renderWithProviders(<EmptyState title="No courses" description="Try another search." />);
    expect(screen.getByText("No courses")).toBeInTheDocument();
    expect(screen.getByText("Try another search.")).toBeInTheDocument();
  });
});

describe("StatusBadge", () => {
  it("renders status text", () => {
    renderWithProviders(<StatusBadge status="published" />);
    expect(screen.getByText("published")).toBeInTheDocument();
  });
});
