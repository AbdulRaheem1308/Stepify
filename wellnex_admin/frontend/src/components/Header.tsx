import React from "react";
import { RefreshCcw, Menu } from "lucide-react";

interface HeaderProps {
  activeTab: string;
  apiKey: string;
  onRefresh: () => void;
  onMenuToggle: () => void;
}

export const Header: React.FC<HeaderProps> = ({ activeTab, apiKey, onRefresh, onMenuToggle }) => {
  return (
    <header className="header">
      <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
        <button
          onClick={onMenuToggle}
          className="btn-icon sidebar-toggle"
          title="Toggle Operations Console Menu"
        >
          <Menu className="w-4 h-4" />
        </button>
        <h2 className="header-title capitalize">{activeTab} Panel</h2>
      </div>
      <div className="flex items-center gap-3" style={{ display: "flex", alignItems: "center", gap: "12px" }}>
        <button
          onClick={onRefresh}
          className="btn-icon"
          title="Refresh ledger state"
        >
          <RefreshCcw className="w-4 h-4" />
        </button>
        <div style={{ height: "16px", width: "1px", backgroundColor: "rgba(255,255,255,0.06)" }}></div>
        <div className="header-meta">
          Session Attestation: <span className="font-mono text-cyan-400" style={{ fontFamily: "monospace", color: "#06b6d4" }}>{apiKey.slice(0, 8)}...</span>
        </div>
      </div>
    </header>
  );
};
