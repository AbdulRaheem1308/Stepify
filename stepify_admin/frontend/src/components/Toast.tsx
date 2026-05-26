import React from "react";
import { Check, AlertTriangle } from "lucide-react";

interface ToastProps {
  toast: { message: string; type: "success" | "error" } | null;
}

export const Toast: React.FC<ToastProps> = ({ toast }) => {
  if (!toast) return null;

  return (
    <div className={`fixed bottom-6 right-6 z-50 flex items-center gap-3 px-5 py-4 rounded-xl border animate-fade-in shadow-xl ${
      toast.type === "success" 
        ? "bg-[#0b1f15]/95 border-emerald-500/30 text-emerald-400 shadow-emerald-950/20" 
        : "bg-[#251010]/95 border-red-500/30 text-red-400 shadow-red-950/20"
    }`}>
      {toast.type === "success" ? <Check className="w-5 h-5" /> : <AlertTriangle className="w-5 h-5" />}
      <span className="text-sm font-semibold">{toast.message}</span>
    </div>
  );
};
