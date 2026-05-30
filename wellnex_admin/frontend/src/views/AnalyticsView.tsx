import React from "react";

interface AnalyticsViewProps {
  interactions: any;
}

export const AnalyticsView: React.FC<AnalyticsViewProps> = ({ interactions }) => {
  if (!interactions) {
    return (
      <div className="animate-fade-in" style={{ display: "flex", alignItems: "center", justifyContent: "center", padding: "48px", color: "var(--text-muted)", fontWeight: "500" }}>
        Loading system interaction tracking records...
      </div>
    );
  }

  return (
    <div className="animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "32px" }}>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: "24px" }}>
        <div className="glass-panel" style={{ padding: "32px" }}>
          <h3 style={{ fontSize: "0.75rem", fontWeight: "700", textTransform: "uppercase", color: "var(--text-muted)", letterSpacing: "1px", marginBottom: "24px" }}>Ad Completion Matrix</h3>
          {interactions.adCompletionStats ? (
            <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem", borderBottom: "1px solid var(--border-color)", paddingBottom: "12px" }}>
                <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Total Video Ads Watched:</span>
                <span style={{ fontWeight: "700", color: "#fff" }}>{interactions.adCompletionStats.totalAdViewsCompleted} Ads</span>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem" }}>
                <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Paid Coins (Ad Rewards):</span>
                <span style={{ fontWeight: "700", color: "var(--primary-light)" }}>{interactions.adCompletionStats.totalCoinsAwardedFromAds.toLocaleString()} 🪙</span>
              </div>
            </div>
          ) : (
            <div style={{ color: "var(--text-muted)", fontSize: "0.75rem", padding: "16px 0", textAlign: "center", fontWeight: "500" }}>No ad logs generated.</div>
          )}
        </div>

        <div className="glass-panel" style={{ padding: "32px" }}>
          <h3 style={{ fontSize: "0.75rem", fontWeight: "700", textTransform: "uppercase", color: "var(--text-muted)", letterSpacing: "1px", marginBottom: "24px" }}>Coin Velocity Indices</h3>
          {interactions.coinVelocity ? (
            <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem", borderBottom: "1px solid var(--border-color)", paddingBottom: "12px" }}>
                <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Coins Minted (Ads Today):</span>
                <span style={{ fontWeight: "700", color: "var(--success)" }}>+{interactions.coinVelocity.totalEarnedFromAds} Coins</span>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem" }}>
                <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Coins Burned (Redemptions):</span>
                <span style={{ fontWeight: "700", color: "var(--error)" }}>-{interactions.coinVelocity.totalRedeemedForRewards} Coins</span>
              </div>
            </div>
          ) : (
            <div style={{ color: "var(--text-muted)", fontSize: "0.75rem", padding: "16px 0", textAlign: "center", fontWeight: "500" }}>No transactions recorded.</div>
          )}
        </div>

        <div className="glass-panel" style={{ padding: "32px" }}>
          <h3 style={{ fontSize: "0.75rem", fontWeight: "700", textTransform: "uppercase", color: "var(--text-muted)", letterSpacing: "1px", marginBottom: "24px" }}>Interaction Duration Index</h3>
          <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem", borderBottom: "1px solid var(--border-color)", paddingBottom: "12px" }}>
              <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Avg. Active Minutes / Day:</span>
              <span style={{ fontWeight: "700", color: "var(--accent)" }}>{interactions.averageActiveMinutesPerDay} Min/Day</span>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.85rem" }}>
              <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Total Tracked Active Minutes:</span>
              <span style={{ fontWeight: "700", color: "#fff" }}>{interactions.totalActiveMinutesLogged} Minutes</span>
            </div>
          </div>
        </div>
      </div>

      {/* Preferences distributions charts */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(340px, 1fr))", gap: "24px" }}>
        <div className="glass-panel" style={{ padding: "32px" }}>
          <h3 className="card-title" style={{ marginBottom: "24px" }}>User Activity Preferences</h3>
          {interactions.preferences && interactions.preferences.length > 0 ? (
            <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
              {interactions.preferences.map((item: any, idx: number) => {
                const total = interactions.preferences.reduce((acc: number, cur: any) => acc + cur.value, 0) || 1;
                const pct = ((item.value / total) * 100).toFixed(0);
                return (
                  <div key={idx} style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", fontWeight: "600" }}>
                      <span style={{ textTransform: "capitalize", color: "#fff" }}>{item.name}</span>
                      <span style={{ color: "var(--text-muted)" }}>{item.value} users ({pct}%)</span>
                    </div>
                    <div className="progress-bar-wrapper">
                      <div style={{ width: `${pct}%`, background: "var(--primary)" }} className="progress-bar" />
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div style={{ color: "var(--text-muted)", fontSize: "0.75rem", padding: "24px 0", textAlign: "center", fontWeight: "500" }}>No preference selections captured.</div>
          )}
        </div>

        <div className="glass-panel" style={{ padding: "32px" }}>
          <h3 className="card-title" style={{ marginBottom: "24px" }}>User Fitness Levels Distribution</h3>
          {interactions.fitnessLevels && interactions.fitnessLevels.length > 0 ? (
            <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
              {interactions.fitnessLevels.map((item: any, idx: number) => {
                const total = interactions.fitnessLevels.reduce((acc: number, cur: any) => acc + cur.value, 0) || 1;
                const pct = ((item.value / total) * 100).toFixed(0);
                return (
                  <div key={idx} style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", fontWeight: "600" }}>
                      <span style={{ textTransform: "capitalize", color: "#fff" }}>{item.name}</span>
                      <span style={{ color: "var(--text-muted)" }}>{item.value} users ({pct}%)</span>
                    </div>
                    <div className="progress-bar-wrapper">
                      <div style={{ width: `${pct}%`, background: "linear-gradient(90deg, var(--primary-light), var(--primary))" }} className="progress-bar" />
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div style={{ color: "var(--text-muted)", fontSize: "0.75rem", padding: "24px 0", textAlign: "center", fontWeight: "500" }}>No fitness levels captured.</div>
          )}
        </div>
      </div>
    </div>
  );
};
