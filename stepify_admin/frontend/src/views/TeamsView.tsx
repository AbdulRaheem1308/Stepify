import React, { useState } from "react";
import { Shield, Trash2, Plus } from "lucide-react";

export const TeamsView: React.FC<any> = ({ teams, battles, onDeleteTeam, onCreateTeam }) => {
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ name: "", isPrivate: false });

  const handleSubmit = (e: any) => {
    e.preventDefault();
    onCreateTeam(form.name, form.isPrivate);
    setShowModal(false);
    setForm({ name: "", isPrivate: false });
  };

  return (
    <div className="space-y-6 animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h3 className="card-title">Corporate & Public Teams</h3>
        <button onClick={() => setShowModal(true)} className="btn btn-primary">
          <Plus className="w-4 h-4" />
          <span>New Team</span>
        </button>
      </div>

      <div className="crud-grid">
        {teams && teams.length > 0 ? teams.map((team: any) => (
          <div key={team.id} className="glass-panel" style={{ padding: "24px", display: "flex", flexDirection: "column", justifyContent: "space-between", gap: "16px" }}>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                <Shield className="w-5 h-5 text-indigo-400" />
                <h4 style={{ fontWeight: "600", color: "#fff" }}>{team.name}</h4>
              </div>
              <button onClick={() => onDeleteTeam(team.id)} className="btn-icon" style={{ color: "var(--error)" }}>
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px", background: "var(--bg-surface-light)", padding: "12px", borderRadius: "6px", border: "1px solid var(--border-color)", fontSize: "0.75rem" }}>
              <div>
                <div style={{ color: "var(--text-muted)", fontSize: "0.65rem", textTransform: "uppercase", fontWeight: "600" }}>Total Steps</div>
                <div style={{ color: "#fff", fontWeight: "600", marginTop: "2px" }}>{team.totalSteps.toLocaleString()}</div>
              </div>
              <div>
                <div style={{ color: "var(--text-muted)", fontSize: "0.65rem", textTransform: "uppercase", fontWeight: "600" }}>Members</div>
                <div style={{ color: "#fff", fontWeight: "600", marginTop: "2px" }}>{team._count?.members || 0} / {team.maxMembers}</div>
              </div>
            </div>
          </div>
        )) : (
          <div style={{ gridColumn: "1/-1", textAlign: "center", color: "var(--text-muted)", padding: "48px" }}>No teams found.</div>
        )}
      </div>

      <h4 style={{ fontSize: "1rem", fontWeight: "600", color: "#fff", marginTop: "32px" }}>Active Team Battles</h4>
      <div className="crud-grid">
        {battles && battles.length > 0 ? battles.map((battle: any) => (
          <div key={battle.id} className="glass-panel" style={{ padding: "16px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "12px" }}>
              <span style={{ fontSize: "0.85rem", fontWeight: "600", color: "#fff" }}>{battle.challenger?.name}</span>
              <span style={{ fontSize: "0.75rem", color: "var(--text-muted)", fontWeight: "600" }}>VS</span>
              <span style={{ fontSize: "0.85rem", fontWeight: "600", color: "#fff" }}>{battle.opponent?.name}</span>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", color: "var(--text-muted)" }}>
              <span>Steps: {battle.challengerSteps}</span>
              <span>Steps: {battle.opponentSteps}</span>
            </div>
          </div>
        )) : (
          <div style={{ gridColumn: "1/-1", textAlign: "center", color: "var(--text-muted)", padding: "24px" }}>No active battles.</div>
        )}
      </div>

      {showModal && (
        <div className="modal-backdrop">
          <div className="modal-dialog">
            <h4 className="modal-title">Create New Team</h4>
            <form onSubmit={handleSubmit} className="modal-form">
              <input type="text" placeholder="Team Name" required value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="search-input" style={{ padding: "14px 16px" }} />
              <label style={{ display: "flex", alignItems: "center", gap: "12px", fontSize: "0.85rem", color: "var(--text-main)", cursor: "pointer", background: "var(--bg-surface-light)", padding: "16px", borderRadius: "8px", border: "1px solid var(--border-color)" }}>
                <input type="checkbox" checked={form.isPrivate} onChange={e => setForm({...form, isPrivate: e.target.checked})} style={{ width: "16px", height: "16px", accentColor: "var(--primary)" }} />
                <span>Private Team <span style={{ color: "var(--text-muted)", fontSize: "0.75rem", display: "block" }}>Requires an invite to join.</span></span>
              </label>
              <div style={{ display: "flex", gap: "12px", marginTop: "12px" }}>
                <button type="button" onClick={() => setShowModal(false)} className="btn btn-secondary flex-1" style={{ padding: "12px" }}>Cancel</button>
                <button type="submit" className="btn btn-primary flex-1" style={{ padding: "12px" }}>Create Team</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
