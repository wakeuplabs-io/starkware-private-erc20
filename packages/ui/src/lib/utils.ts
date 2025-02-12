import { DECIMALS } from "@/constants";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const formatHex = (value: bigint): string => {
  return "0x" + value.toString(16);
};

export const shortenAddress = (address: string): string => {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
};

export const formatTokenAmount = (value: bigint): string => {
  const factor = 10n ** DECIMALS;
  const integerPart = value / factor;
  const decimalPart = value % factor;
  return `${integerPart}.${decimalPart.toString().padStart(parseInt(DECIMALS.toString()), "0").slice(0, 2)}`;
};
