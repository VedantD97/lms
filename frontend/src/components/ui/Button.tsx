import { cn } from "@/lib/utils/cn";
import type { ButtonHTMLAttributes } from "react";

export function Button({
  className,
  variant = "primary",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: "primary" | "secondary" | "danger" }) {
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center rounded-lg px-4 py-2.5 text-sm font-semibold transition duration-150 disabled:cursor-not-allowed disabled:opacity-50",
        variant === "primary" && "bg-brand text-white shadow-sm hover:bg-brand-hover active:scale-[0.98]",
        variant === "secondary" &&
          "border border-line bg-white text-ink shadow-sm hover:border-brand/40 hover:bg-brand-muted/40",
        variant === "danger" && "bg-red-600 text-white hover:bg-red-700 active:scale-[0.98]",
        className,
      )}
      {...props}
    />
  );
}
