import React from "react";
import { Plus, Edit3, Trash2, X } from "lucide-react";

interface QuestStage {
  id: string;
  order: number;
  title: string;
  description: string;
  targetSteps: number;
}

interface Quest {
  id: string;
  title: string;
  description: string;
  imageUrl: string;
  difficulty: string;
  rewardXp: number;
  rewardCoins: number;
  isActive: boolean;
  stages?: QuestStage[];
}

interface QuestsViewProps {
  quests: Quest[];
  onOpenCreateModal: () => void;
  onOpenEditModal: (quest: Quest) => void;
  onDeleteQuest: (id: string) => void;
  onOpenStageModal: (questId: string) => void;
  onDeleteStage: (stageId: string) => void;
}

export const QuestsView: React.FC<QuestsViewProps> = ({
  quests,
  onOpenCreateModal,
  onOpenEditModal,
  onDeleteQuest,
  onOpenStageModal,
  onDeleteStage
}) => {
  return (
    <div className="animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h3 className="card-title">Interactive Quest Pipelines</h3>
        <button
          onClick={onOpenCreateModal}
          className="btn btn-primary"
        >
          <Plus className="w-4 h-4" />
          <span>Create Quest Chain</span>
        </button>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
        {quests.map(quest => (
          <div key={quest.id} className="glass-panel" style={{ padding: "32px", display: "flex", flexDirection: "column", gap: "24px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", borderBottom: "1px solid var(--border-color)", paddingBottom: "24px" }}>
              <div>
                <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                  <h4 style={{ fontSize: "1.1rem", fontWeight: "700", color: "#fff" }}>{quest.title}</h4>
                  <span className={`badge-difficulty ${
                    quest.difficulty === "EASY" ? "badge-diff-easy" :
                    quest.difficulty === "MEDIUM" ? "badge-diff-medium" : "badge-diff-hard"
                  }`}>
                    {quest.difficulty}
                  </span>
                </div>
                <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "8px", maxWidth: "600px", lineHeight: "1.5" }}>{quest.description}</p>
              </div>

              <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
                <div style={{ textAlign: "right", display: "flex", gap: "12px", alignItems: "center" }}>
                  <span style={{ fontSize: "0.8rem", fontWeight: "700", color: "var(--warning)" }}>+{quest.rewardCoins} Coins</span>
                  <span style={{ fontSize: "0.8rem", fontWeight: "700", color: "var(--primary-light)" }}>+{quest.rewardXp} XP</span>
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                  <button 
                    onClick={() => onOpenStageModal(quest.id)}
                    className="btn btn-secondary"
                    style={{ padding: "6px 12px", fontSize: "0.75rem" }}
                  >
                    Add Stage
                  </button>
                  <button 
                    onClick={() => onOpenEditModal(quest)}
                    className="btn-icon"
                    style={{ padding: "6px" }}
                  >
                    <Edit3 className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => onDeleteQuest(quest.id)}
                    className="btn-icon"
                    style={{ padding: "6px", color: "var(--error)" }}
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>

            {/* Pipeline Stages flow */}
            <div>
              <h5 style={{ fontSize: "0.75rem", fontWeight: "700", color: "var(--text-muted)", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "16px" }}>Quest Pipeline Stage Flow</h5>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))", gap: "16px" }}>
                {quest.stages && quest.stages.length > 0 ? (
                  quest.stages.sort((a, b) => a.order - b.order).map((st) => (
                    <div key={st.id} className="pipeline-stage hover:border-primary transition-all duration-200" style={{ display: "flex", flexDirection: "column", justifyContent: "space-between", minHeight: "130px" }}>
                      <div style={{ position: "absolute", top: "12px", right: "12px" }}>
                        <button
                          onClick={() => onDeleteStage(st.id)}
                          style={{ background: "transparent", border: "none", color: "var(--error)", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", padding: "4px", opacity: 0.7 }}
                          onMouseOver={(e) => (e.currentTarget.style.opacity = "1")}
                          onMouseOut={(e) => (e.currentTarget.style.opacity = "0.7")}
                        >
                          <X className="w-4 h-4" />
                        </button>
                      </div>
                      <div>
                        <span style={{ fontSize: "0.65rem", fontWeight: "700", color: "var(--primary-light)", textTransform: "uppercase", letterSpacing: "0.5px" }}>Stage {st.order}</span>
                        <h6 style={{ fontSize: "0.85rem", fontWeight: "700", color: "#fff", marginTop: "4px" }}>{st.title}</h6>
                        <p style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "6px", lineHeight: "1.4", overflow: "hidden", textOverflow: "ellipsis", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", height: "32px" }}>{st.description}</p>
                      </div>
                      <div style={{ borderTop: "1px solid var(--border-color)", paddingTop: "8px", marginTop: "12px", fontSize: "0.75rem", fontWeight: "700", color: "var(--accent)" }}>
                        Target: {st.targetSteps.toLocaleString()} steps
                      </div>
                    </div>
                  ))
                ) : (
                  <div style={{ gridColumn: "1 / -1", padding: "24px 0", textAlign: "center", fontSize: "0.8rem", color: "var(--text-muted)", fontWeight: "500" }}>
                    No pipeline stages configured. Click "Add Stage" above to design the user progression flow.
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}
        {quests.length === 0 && (
          <div className="glass-panel" style={{ padding: "48px", textAlign: "center", color: "var(--text-muted)", fontSize: "0.85rem", fontWeight: "500" }}>
            No active quest chains. Begin creating quest pipelines to increase daily user retention!
          </div>
        )}
      </div>
    </div>
  );
};
