import React from "react";

interface StatCardProps {
  title: string;
  value: string | number;
  subtitle: string;
}

export const StatCard: React.FC<StatCardProps> = ({ title, value, subtitle }) => {
  return (
    <div className="glass-panel p-6 relative overflow-hidden group hover:-translate-y-1 transition-all">
      <div className="relative z-10 flex flex-col justify-between h-full">
        <span className="text-xs font-extrabold text-slate-400 uppercase tracking-wider">{title}</span>
        <span className="text-3xl font-black mt-3 bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">{value}</span>
        <span className="text-[11px] text-slate-500 mt-2 font-medium">{subtitle}</span>
      </div>
      <div className="absolute -bottom-6 -right-6 w-20 h-20 bg-gradient-to-tr from-violet-600 to-cyan-500 opacity-5 blur-xl group-hover:opacity-10 transition-all rounded-full" />
    </div>
  );
};
