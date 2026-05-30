import React from "react";

interface ChartDataPoint {
  date: string;
  steps: number;
}

interface ActivityChartProps {
  chartData: ChartDataPoint[];
}

export const ActivityChart: React.FC<ActivityChartProps> = ({ chartData }) => {
  if (!chartData || chartData.length === 0) {
    return (
      <div style={{ height: "250px", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "0.85rem", color: "var(--text-muted)", fontWeight: "600" }}>
        No steps ledger records available to stream.
      </div>
    );
  }

  const maxVal = Math.max(...chartData.map(x => x.steps)) || 1;

  return (
    <div style={{ height: "250px", display: "flex", alignItems: "flex-end", justifyContent: "space-between", gap: "8px", paddingTop: "24px" }}>
      {chartData.map((d, idx) => {
        const pct = (d.steps / maxVal) * 80 + 10;
        return (
          <div key={idx} className="group" style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: "8px", height: "100%", justifyContent: "flex-end", cursor: "pointer" }}>
            <div className="opacity-0 group-hover:opacity-100 transition-all" style={{ fontSize: "0.65rem", fontWeight: "700", color: "#fff", background: "var(--bg-surface-hover)", border: "1px solid var(--border-color)", padding: "4px 6px", borderRadius: "4px", transform: "translateY(-4px)" }}>
              {d.steps.toLocaleString()}
            </div>
            <div 
              style={{ height: `${pct}%`, width: "100%", maxWidth: "40px", borderRadius: "4px 4px 0 0", background: "var(--primary)", transition: "all 0.2s ease" }}
              className="group-hover:brightness-110"
            />
            <span style={{ fontSize: "0.65rem", color: "var(--text-muted)", fontWeight: "600", width: "100%", textAlign: "center", textOverflow: "ellipsis", overflow: "hidden", whiteSpace: "nowrap", marginTop: "4px" }}>
              {d.date.slice(5)}
            </span>
          </div>
        );
      })}
    </div>
  );
};
