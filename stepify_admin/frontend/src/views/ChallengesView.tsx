import React from "react";
import { Plus, Edit3, Trash2 } from "lucide-react";

interface Challenge {
  id: string;
  title: string;
  description: string;
  stepTarget: number;
  rewardCoins: number;
  rewardXp: number;
  durationDays: number;
  challengeType: string;
  difficulty: string;
  imageUrl: string | null;
  isActive: boolean;
}

interface ChallengesViewProps {
  challenges: Challenge[];
  onOpenCreateModal: () => void;
  onOpenEditModal: (challenge: Challenge) => void;
  onDeleteChallenge: (id: string) => void;
}

export const ChallengesView: React.FC<ChallengesViewProps> = ({
  challenges,
  onOpenCreateModal,
  onOpenEditModal,
  onDeleteChallenge
}) => {
  return (
    <div className="space-y-6 animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h3 className="card-title">Campaign Challenges</h3>
        <button
          onClick={onOpenCreateModal}
          className="btn btn-primary"
        >
          <Plus className="w-4 h-4" />
          <span>Create Challenge</span>
        </button>
      </div>

      <div className="crud-grid">
        {challenges.map(item => (
          <div key={item.id} className="glass-panel p-6" style={{ padding: "24px", display: "flex", flexDirection: "column", justifyContent: "space-between", position: "relative", overflow: "hidden" }}>
            <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <span className={`badge-difficulty ${
                  item.difficulty === "EASY" ? "badge-diff-easy" :
                  item.difficulty === "MEDIUM" ? "badge-diff-medium" : "badge-diff-hard"
                }`}>
                  {item.difficulty}
                </span>
                <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                  <button 
                    onClick={() => onOpenEditModal(item)}
                    className="btn-icon"
                    style={{ padding: "6px" }}
                  >
                    <Edit3 className="w-3.5 h-3.5" />
                  </button>
                  <button 
                    onClick={() => onDeleteChallenge(item.id)}
                    className="btn-icon"
                    style={{ padding: "6px", color: "var(--error)" }}
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>

              <div>
                <h4 style={{ fontSize: "1rem", fontWeight: "700", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", color: "#fff" }}>{item.title}</h4>
                <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "8px", lineHeight: "1.4", overflow: "hidden", textOverflow: "ellipsis", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", height: "36px" }}>
                  {item.description}
                </p>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px", background: "var(--bg-surface-light)", padding: "16px", borderRadius: "8px", border: "1px solid var(--border-color)", fontSize: "0.75rem" }}>
                <div>
                  <div style={{ fontSize: "0.65rem", color: "var(--text-muted)", fontStyle: "normal", textTransform: "uppercase", fontWeight: "600" }}>Target Steps</div>
                  <div style={{ fontWeight: "700", color: "#fff", marginTop: "4px" }}>{item.stepTarget.toLocaleString()}</div>
                </div>
                <div>
                  <div style={{ fontSize: "0.65rem", color: "var(--text-muted)", fontStyle: "normal", textTransform: "uppercase", fontWeight: "600" }}>Time Period</div>
                  <div style={{ fontWeight: "700", color: "#fff", marginTop: "4px" }}>{item.durationDays} Days</div>
                </div>
              </div>
            </div>

            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", borderTop: "1px solid var(--border-color)", paddingTop: "16px", marginTop: "24px" }}>
              <div style={{ display: "flex", gap: "12px" }}>
                <span style={{ fontSize: "0.75rem", fontWeight: "700", color: "var(--accent)" }}>+{item.rewardCoins} Coins</span>
                <span style={{ fontSize: "0.75rem", fontWeight: "700", color: "var(--primary-light)" }}>+{item.rewardXp} XP</span>
              </div>
              <span style={{ fontSize: "0.65rem", fontWeight: "700", textTransform: "uppercase", color: item.isActive ? "var(--success)" : "var(--text-muted)", letterSpacing: "0.5px" }}>
                {item.isActive ? "● Active" : "○ Draft"}
              </span>
            </div>
          </div>
        ))}
        {challenges.length === 0 && (
          <div style={{ gridColumn: "span 3", padding: "48px 0", textAlign: "center", color: "var(--text-muted)", fontSize: "0.85rem", fontWeight: "500" }}>
            No campaign challenges configured. Create one to keep users engaged!
          </div>
        )}
      </div>
    </div>
  );
};
