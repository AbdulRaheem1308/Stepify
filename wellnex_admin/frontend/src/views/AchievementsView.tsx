import React from "react";
import { Plus, Edit3, Trash2 } from "lucide-react";

interface Achievement {
  id: string;
  code: string;
  name: string;
  description: string;
  icon: string;
  category: string;
  pointsReward: number;
  stepsRequired: number | null;
  streakRequired: number | null;
  targetValue: number | null;
  isActive: boolean;
}

interface AchievementsViewProps {
  achievements: Achievement[];
  onOpenCreateModal: () => void;
  onOpenEditModal: (achievement: Achievement) => void;
  onDeleteAchievement: (id: string) => void;
}

export const AchievementsView: React.FC<AchievementsViewProps> = ({
  achievements,
  onOpenCreateModal,
  onOpenEditModal,
  onDeleteAchievement
}) => {
  return (
    <div className="space-y-6 animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h3 className="card-title">Milestone Achievement Badges</h3>
        <button
          onClick={onOpenCreateModal}
          className="btn btn-primary"
        >
          <Plus className="w-4 h-4" />
          <span>Create Badge</span>
        </button>
      </div>

      <div className="crud-grid" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))" }}>
        {achievements.map(item => (
          <div key={item.id} className="glass-panel p-6" style={{ padding: "32px", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
            <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "start" }}>
                <div style={{
                  width: "48px",
                  height: "48px",
                  borderRadius: "12px",
                  backgroundColor: "var(--bg-surface-light)",
                  border: "1px solid var(--border-color)",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: "1.25rem"
                }}>
                  🏆
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                  <button 
                    onClick={() => onOpenEditModal(item)}
                    className="btn-icon"
                    style={{ padding: "6px" }}
                  >
                    <Edit3 className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => onDeleteAchievement(item.id)}
                    className="btn-icon"
                    style={{ padding: "6px", color: "var(--error)" }}
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <div>
                <h4 style={{ fontSize: "1.1rem", fontWeight: "700" }}>{item.name}</h4>
                <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "8px", lineHeight: "1.5", overflow: "hidden", textOverflow: "ellipsis", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", height: "36px" }}>
                  {item.description}
                </p>
              </div>

              <div style={{ fontSize: "0.75rem", display: "flex", flexDirection: "column", gap: "12px", backgroundColor: "var(--bg-surface-light)", padding: "16px", borderRadius: "8px", border: "1px solid var(--border-color)" }}>
                <div style={{ display: "flex", justifyContent: "space-between" }}>
                  <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Unique Code:</span>
                  <span style={{ fontFamily: "monospace", color: "var(--accent)", fontWeight: "700", letterSpacing: "0.5px" }}>{item.code}</span>
                </div>
                <div style={{ display: "flex", justifyContent: "space-between" }}>
                  <span style={{ color: "var(--text-muted)", fontWeight: "500" }}>Target Metric:</span>
                  <span style={{ fontWeight: "700", color: "#fff" }}>
                    {item.stepsRequired ? `${item.stepsRequired.toLocaleString()} steps` :
                     item.streakRequired ? `${item.streakRequired} streak days` :
                     item.targetValue ? `${item.targetValue} units` : "Special"}
                  </span>
                </div>
              </div>
            </div>

            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", borderTop: "1px solid var(--border-color)", paddingTop: "16px", marginTop: "24px" }}>
              <span style={{ fontSize: "0.75rem", fontWeight: "700", color: "var(--warning)" }}>+{item.pointsReward} Coins Bonus</span>
              <span style={{ fontSize: "0.65rem", fontWeight: "700", textTransform: "uppercase", color: item.isActive ? "var(--success)" : "var(--text-muted)", letterSpacing: "0.5px" }}>
                {item.isActive ? "● Live" : "○ Hidden"}
              </span>
            </div>
          </div>
        ))}
        {achievements.length === 0 && (
          <div style={{ gridColumn: "span 4", padding: "48px 0", textAlign: "center", color: "var(--text-muted)", fontSize: "0.85rem", fontWeight: "500" }}>
            No achievement badges configured yet.
          </div>
        )}
      </div>
    </div>
  );
};
