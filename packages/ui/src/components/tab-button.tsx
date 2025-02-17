import { cn } from "@/lib/utils";
import { ButtonProps } from "./ui/button";

export const TabButton: React.FC<ButtonProps & { active?: boolean }> = ({
  className,
  children,
  active,
  ...props
}) => {
  return (
    <button
      disabled={active}
      className={cn(
        "h-9 px-3 text-sm border border-input hover:bg-accent bg-transparent rounded-lg border-primary flex items-center gap-1",
        {
          "bg-gradient-to-r from-[#9A5583] via-[#35269A] to-[#181972] text-white border-none":
            active,
        },
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
};
