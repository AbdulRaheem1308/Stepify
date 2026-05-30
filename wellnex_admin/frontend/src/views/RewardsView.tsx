import React from "react";
import { Plus, Edit3, Trash2 } from "lucide-react";

interface Reward {
  id: string;
  title: string;
  description: string;
  coinCost: number;
  category: string;
  imageUrl: string | null;
  partnerName: string | null;
  partnerLogoUrl: string | null;
  availableStock: number;
  totalStock: number;
  isActive: boolean;
}

interface RewardsViewProps {
  rewards: Reward[];
  onOpenCreateModal: () => void;
  onOpenEditModal: (reward: Reward) => void;
  onDeleteReward: (id: string) => void;
}

export const RewardsView: React.FC<RewardsViewProps> = ({
  rewards,
  onOpenCreateModal,
  onOpenEditModal,
  onDeleteReward
}) => {
  return (
    <div className="animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h3 className="card-title">Partner Rewards Catalog</h3>
        <button
          onClick={onOpenCreateModal}
          className="btn btn-primary"
        >
          <Plus className="w-4 h-4" />
          <span>Add Reward Item</span>
        </button>
      </div>

      <div className="crud-grid">
        {rewards.map(item => (
          <div key={item.id} className="glass-panel hover:border-primary transition-all duration-200" style={{ display: "flex", flexDirection: "column", justifyContent: "space-between", overflow: "hidden", position: "relative" }}>
            <div style={{ padding: "32px", display: "flex", flexDirection: "column", gap: "20px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <span style={{ padding: "4px 10px", borderRadius: "6px", background: "var(--bg-surface-light)", border: "1px solid var(--border-color)", fontSize: "0.65rem", fontWeight: "700", letterSpacing: "1px", textTransform: "uppercase", color: "var(--accent)" }}>
                  {item.category}
                </span>
                <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                  <button 
                    onClick={() => onOpenEditModal(item)}
                    className="btn-icon"
                    style={{ padding: "6px" }}
                  >
                    <Edit3 className="w-4 h-4" />
                  </button>
                  <button 
                    onClick={() => onDeleteReward(item.id)}
                    className="btn-icon"
                    style={{ padding: "6px", color: "var(--error)" }}
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <div>
                <h4 style={{ fontSize: "1.1rem", fontWeight: "700", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", color: "#fff" }}>{item.title}</h4>
                <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "6px", lineHeight: "1.5", overflow: "hidden", textOverflow: "ellipsis", display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", height: "36px" }}>{item.description}</p>
                <p style={{ fontSize: "0.75rem", color: "var(--primary-light)", fontWeight: "600", marginTop: "12px", textTransform: "uppercase", letterSpacing: "0.5px" }}>Partner: {item.partnerName || "General"}</p>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px", background: "var(--bg-surface-light)", padding: "16px", borderRadius: "8px", border: "1px solid var(--border-color)", fontSize: "0.75rem" }}>
                <div>
                  <div style={{ fontSize: "0.65rem", color: "var(--text-muted)", textTransform: "uppercase", fontWeight: "600" }}>Coin Cost</div>
                  <div style={{ fontWeight: "700", color: "var(--warning)", marginTop: "4px" }}>{item.coinCost} 🪙</div>
                </div>
                <div>
                  <div style={{ fontSize: "0.65rem", color: "var(--text-muted)", textTransform: "uppercase", fontWeight: "600" }}>Voucher Stock</div>
                  <div style={{ fontWeight: "700", color: "#fff", marginTop: "4px" }}>
                    {item.availableStock === -1 ? "Unlimited" : `${item.availableStock}/${item.totalStock}`}
                  </div>
                </div>
              </div>
            </div>

            <div style={{ padding: "16px 32px", background: "var(--bg-surface-light)", borderTop: "1px solid var(--border-color)", display: "flex", alignItems: "center", justifyContent: "space-between", fontSize: "0.7rem", fontWeight: "700", textTransform: "uppercase", letterSpacing: "0.5px" }}>
              <span style={{ color: item.isActive ? "var(--success)" : "var(--text-muted)" }}>
                {item.isActive ? "● In Stock" : "○ Suspended"}
              </span>
              <span style={{ color: "var(--text-muted)", fontSize: "0.65rem" }}>ID: {item.id.slice(0, 8)}</span>
            </div>
          </div>
        ))}
        {rewards.length === 0 && (
          <div style={{ gridColumn: "span 3", padding: "48px 0", textAlign: "center", color: "var(--text-muted)", fontSize: "0.85rem", fontWeight: "500" }}>
            No active reward catalog items set up.
          </div>
        )}
      </div>
    </div>
  );
};
