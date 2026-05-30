import React from "react";
import { Shield, ArrowRight } from "lucide-react";
import { StatCard } from "../components/StatCard";
import { ActivityChart } from "../components/ActivityChart";

interface DashboardViewProps {
  summary: any;
  onNavigateToAnalytics: () => void;
}

export const DashboardView: React.FC<DashboardViewProps> = ({ summary, onNavigateToAnalytics }) => {
  if (!summary) {
    return (
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center", padding: "48px", color: "var(--text-muted)", fontWeight: "600" }}>
        Loading system metrics ledger...
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "32px" }}>
      {/* Stat Cards */}
      <div className="grid-stats">
        <StatCard 
          title="Registered Users" 
          value={summary.totalUsers} 
          subtitle={`${summary.activeUsers} active session profiles`} 
        />
        <StatCard 
          title="Steps Tracked" 
          value={(summary.totalSteps || 0).toLocaleString()} 
          subtitle="Cumulative aggregate logs" 
        />
        <StatCard 
          title="Awarded Coins" 
          value={(summary.totalCoins || 0).toLocaleString()} 
          subtitle="Held inside user wallets" 
        />
        <StatCard 
          title="Ad Conversions" 
          value={summary.totalAdViews} 
          subtitle="Monetized video views" 
        />
      </div>

      {/* Activity Chart container */}
      <div className="glass-panel p-6" style={{ padding: "32px" }}>
        <div className="card-title-section">
          <div>
            <h3 className="card-title">Weekly Activity Stream</h3>
            <p className="card-desc">Aggregated daily fitness metrics</p>
          </div>
          <span style={{ fontSize: "0.75rem", fontWeight: "600", color: "var(--primary-light)", backgroundColor: "var(--bg-surface-light)", border: "1px solid var(--border-color)", padding: "4px 12px", borderRadius: "20px" }}>Prisma DB Active</span>
        </div>
        
        <ActivityChart chartData={summary.chartData} />
      </div>

      {/* Auxiliary Security & Corporate panel */}
      <div className="grid-twocol">
        <div className="glass-panel p-6" style={{ padding: "32px" }}>
          <h3 className="card-title" style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "24px" }}>
            <Shield className="w-5 h-5 text-primary" />
            <span>Security & Anti-Exploit Summary</span>
          </h3>
          <div style={{ display: "flex", flexDirection: "column", gap: "16px", fontSize: "0.85rem" }}>
            <div style={{ display: "flex", justifyContent: "space-between", borderBottom: "1px solid var(--border-color)", paddingBottom: "12px" }}>
              <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Attestation Shield Status:</span>
              <span style={{ color: "var(--success)", fontWeight: "600" }}>100% Cryptographic Lock</span>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", borderBottom: "1px solid var(--border-color)", paddingBottom: "12px" }}>
              <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Replay Nonce Caching:</span>
              <span style={{ color: "var(--accent)", fontFamily: "monospace", fontWeight: "600" }}>Redis Active</span>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Suspicious Anomalies Stopped Today:</span>
              <span style={{ color: "var(--warning)", fontWeight: "600" }}>0 Blocks</span>
            </div>
          </div>
        </div>

        <div className="glass-panel p-6" style={{ padding: "32px", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
          <div>
            <h3 className="card-title">Corporate Wellness Channels</h3>
            <p className="card-desc" style={{ marginTop: "8px" }}>Active company partnerships connected to the real-time wellness gateway.</p>
          </div>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", borderTop: "1px solid var(--border-color)", paddingTop: "24px", marginTop: "24px" }}>
            <div>
              <span style={{ fontSize: "1.75rem", fontWeight: "700", color: "#fff" }}>{summary.totalCompanies}</span>
              <span style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginLeft: "8px", fontWeight: "500" }}>Active companies</span>
            </div>
            <button 
              onClick={onNavigateToAnalytics} 
              className="btn btn-secondary"
              style={{ padding: "8px 16px", textTransform: "none", fontSize: "0.75rem" }}
            >
              <span>Analyze Preferences</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
