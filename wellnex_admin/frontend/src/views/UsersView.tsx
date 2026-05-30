import React from "react";
import { Search, Eye } from "lucide-react";

interface User {
  id: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  isActive: boolean;
  streak?: { currentStreak: number; longestStreak: number };
  wallet?: { balance: number; lifetimePoints: number };
  steps?: { id: string; date: string; stepCount: number }[];
  transactions?: { id: string; description: string | null; type: string; points: number }[];
}

interface UsersViewProps {
  users: User[];
  selectedUser: any;
  userSearch: string;
  setUserSearch: (search: string) => void;
  onSelectUser: (id: string) => void;
  onToggleStatus: (id: string) => void;
}

export const UsersView: React.FC<UsersViewProps> = ({
  users,
  selectedUser,
  userSearch,
  setUserSearch,
  onSelectUser,
  onToggleStatus
}) => {
  return (
    <div className="space-y-6 animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      <div className="search-input-wrapper">
        <Search className="search-icon" />
        <input
          type="text"
          value={userSearch}
          onChange={(e) => setUserSearch(e.target.value)}
          placeholder="Search by username, email, phone..."
          className="search-input"
        />
      </div>

      <div className="grid-twocol">
        {/* User Pool Grid */}
        <div className="glass-panel overflow-hidden" style={{ borderRadius: "12px" }}>
          <div style={{ padding: "24px", borderBottom: "1px solid var(--border-color)" }}>
            <h3 className="card-title">Registered Users Pool</h3>
          </div>
          <div style={{ overflowY: "auto", maxHeight: "600px", display: "flex", flexDirection: "column", gap: "4px", padding: "12px 0" }}>
            {users.map(u => (
              <div 
                key={u.id}
                className={`user-item ${selectedUser?.id === u.id ? "user-item-active" : ""}`}
                onClick={() => onSelectUser(u.id)}
              >
                <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                  <div className="avatar-circle">
                    {(u.name || "U")[0].toUpperCase()}
                  </div>
                  <div>
                    <div style={{ fontSize: "0.85rem", fontWeight: "600", display: "flex", alignItems: "center", gap: "8px" }}>
                      <span style={{ color: selectedUser?.id === u.id ? "#fff" : "var(--text-main)" }}>{u.name || "Unnamed User"}</span>
                      {!u.isActive && <span className="badge-status badge-status-inactive">DEACTIVATED</span>}
                    </div>
                    <div style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "2px", maxWidth: "200px", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                      {u.email || u.phone || u.id}
                    </div>
                  </div>
                </div>

                <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
                  <div style={{ textAlign: "right" }}>
                    <div style={{ fontSize: "0.8rem", fontWeight: "600", color: "var(--primary-light)" }}>{(u.wallet?.balance || 0).toLocaleString()} 🪙</div>
                    <div style={{ fontSize: "0.7rem", color: "var(--text-muted)", marginTop: "2px", fontWeight: "500" }}>{(u.streak?.currentStreak || 0)} day streak</div>
                  </div>
                  <button
                    onClick={(e) => { e.stopPropagation(); onToggleStatus(u.id); }}
                    className={`btn ${u.isActive ? "btn-danger" : "btn-primary"}`}
                    style={{ padding: "6px 12px", fontSize: "0.7rem" }}
                  >
                    {u.isActive ? "Deactivate" : "Activate"}
                  </button>
                </div>
              </div>
            ))}
            {users.length === 0 && (
              <div style={{ padding: "32px", textAlign: "center", fontSize: "0.85rem", color: "var(--text-muted)" }}>
                No profiles match search query.
              </div>
            )}
          </div>
        </div>

        {/* Profile Auditor Inspector Panel */}
        <div className="glass-panel p-6" style={{ padding: "32px", display: "flex", flexDirection: "column", justifyContent: "space-between", minHeight: "500px" }}>
          {selectedUser ? (
            <div style={{ display: "flex", flexDirection: "column", gap: "24px", animation: "fadeIn 0.2s ease" }}>
              <div className="inspector-header">
                <div className="inspector-avatar">
                  {(selectedUser.name || "U")[0].toUpperCase()}
                </div>
                <h4 style={{ fontSize: "1.125rem", fontWeight: "700", color: "#fff" }}>{selectedUser.name || "Unnamed Profile"}</h4>
                <p style={{ fontSize: "0.8rem", color: "var(--text-muted)", marginTop: "4px" }}>{selectedUser.email || selectedUser.phone || selectedUser.id}</p>
              </div>

              <div className="inspector-stats-grid">
                <div className="inspector-stat-box">
                  <div className="inspector-stat-lbl">Balance</div>
                  <div className="inspector-stat-val" style={{ color: "var(--primary-light)" }}>{selectedUser.wallet?.balance || 0} 🪙</div>
                </div>
                <div className="inspector-stat-box">
                  <div className="inspector-stat-lbl">Active Streak</div>
                  <div className="inspector-stat-val" style={{ color: "var(--accent)" }}>{selectedUser.streak?.currentStreak || 0} Days</div>
                </div>
              </div>

              <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
                <h5 style={{ fontSize: "0.75rem", fontWeight: "600", color: "var(--text-muted)", textTransform: "uppercase" }}>Step Logs (Recent 5)</h5>
                <div style={{ display: "flex", flexDirection: "column", gap: "8px", maxHeight: "150px", overflowY: "auto", paddingRight: "4px" }}>
                  {selectedUser.steps && selectedUser.steps.map((st: any) => (
                    <div key={st.id} style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", padding: "12px 16px", background: "var(--bg-surface-light)", border: "1px solid var(--border-color)", borderRadius: "6px" }}>
                      <span style={{ fontWeight: "600", color: "var(--text-muted)" }}>{st.date.slice(0, 10)}</span>
                      <span style={{ fontWeight: "600", color: "var(--primary-light)" }}>{st.stepCount.toLocaleString()} steps</span>
                    </div>
                  ))}
                  {(!selectedUser.steps || selectedUser.steps.length === 0) && (
                    <div style={{ fontSize: "0.75rem", color: "var(--text-muted)", fontStyle: "italic", textAlign: "center", padding: "16px 0" }}>No step sync logs.</div>
                  )}
                </div>
              </div>

              <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
                <h5 style={{ fontSize: "0.75rem", fontWeight: "600", color: "var(--text-muted)", textTransform: "uppercase" }}>Transaction Audits</h5>
                <div style={{ display: "flex", flexDirection: "column", gap: "8px", maxHeight: "150px", overflowY: "auto", paddingRight: "4px" }}>
                  {selectedUser.transactions && selectedUser.transactions.map((tx: any) => (
                    <div key={tx.id} style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", padding: "12px 16px", background: "var(--bg-surface-light)", border: "1px solid var(--border-color)", borderRadius: "6px" }}>
                      <span style={{ fontWeight: "600", color: "var(--text-muted)", textOverflow: "ellipsis", overflow: "hidden", whiteSpace: "nowrap", maxWidth: "120px" }}>{tx.description || tx.type}</span>
                      <span style={{ fontWeight: "700", color: tx.points >= 0 ? "var(--success)" : "var(--error)" }}>
                        {tx.points >= 0 ? `+${tx.points}` : tx.points} 🪙
                      </span>
                    </div>
                  ))}
                  {(!selectedUser.transactions || selectedUser.transactions.length === 0) && (
                    <div style={{ fontSize: "0.75rem", color: "var(--text-muted)", fontStyle: "italic", textAlign: "center", padding: "16px 0" }}>No balance logs.</div>
                  )}
                </div>
              </div>
            </div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", flex: "1", color: "var(--text-muted)", textAlign: "center", gap: "12px" }}>
              <Eye className="w-10 h-10 opacity-30 text-primary" />
              <div style={{ fontSize: "0.85rem", fontWeight: "500" }}>Select a user profile to inspect sync records and ledger audits.</div>
            </div>
          )}
          <div style={{ borderTop: "1px solid var(--border-color)", marginTop: "32px", paddingTop: "16px", textAlign: "center" }}>
            <p style={{ fontSize: "0.65rem", color: "var(--text-muted)", fontWeight: "500" }}>Wellnex Compliance & Verification Framework</p>
          </div>
        </div>
      </div>
    </div>
  );
};
