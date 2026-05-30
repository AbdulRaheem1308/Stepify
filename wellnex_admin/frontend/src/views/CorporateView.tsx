import React, { useState } from "react";
import { Building2, Trash2, Plus } from "lucide-react";

export const CorporateView: React.FC<any> = ({ companies, onDeleteCompany, onCreateCompany }) => {
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ name: "", domain: "" });

  const handleSubmit = (e: any) => {
    e.preventDefault();
    onCreateCompany(form.name, form.domain);
    setShowModal(false);
    setForm({ name: "", domain: "" });
  };

  return (
    <div className="space-y-6 animate-fade-in" style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h3 className="card-title">Corporate Wellness B2B</h3>
        <button onClick={() => setShowModal(true)} className="btn btn-primary">
          <Plus className="w-4 h-4" />
          <span>Onboard Company</span>
        </button>
      </div>

      <div className="crud-grid">
        {companies && companies.length > 0 ? companies.map((company: any) => (
          <div key={company.id} className="glass-panel" style={{ padding: "24px", display: "flex", flexDirection: "column", gap: "16px" }}>
            <div style={{ display: "flex", justifyContent: "space-between" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                <div style={{ background: "var(--bg-surface-light)", padding: "10px", borderRadius: "8px", border: "1px solid var(--border-color)" }}>
                  <Building2 className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <h4 style={{ fontWeight: "700", color: "#fff" }}>{company.name}</h4>
                  <div style={{ fontSize: "0.75rem", color: "var(--text-muted)", marginTop: "2px", fontWeight: "500" }}>@{company.domain || "no-domain"}</div>
                </div>
              </div>
              <button onClick={() => onDeleteCompany(company.id)} className="btn-icon" style={{ color: "var(--error)" }}>
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
            
            <div style={{ background: "var(--bg-surface-light)", padding: "16px", borderRadius: "8px", border: "1px solid var(--border-color)", fontSize: "0.75rem" }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "12px" }}>
                <span style={{ color: "var(--text-muted)", fontWeight: "600" }}>Invite Code</span>
                <span style={{ color: "var(--primary-light)", fontWeight: "700", fontFamily: "monospace", letterSpacing: "0.5px" }}>{company.inviteCode}</span>
              </div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: "8px", paddingTop: "12px", borderTop: "1px solid var(--border-color)" }}>
                <div>
                  <div style={{ fontSize: "0.65rem", color: "var(--text-muted)", textTransform: "uppercase", fontWeight: "600" }}>Members</div>
                  <div style={{ color: "#fff", fontWeight: "700", marginTop: "4px" }}>{company._count?.members || 0}</div>
                </div>
                <div>
                  <div style={{ fontSize: "0.65rem", color: "var(--text-muted)", textTransform: "uppercase", fontWeight: "600" }}>Depts</div>
                  <div style={{ color: "#fff", fontWeight: "700", marginTop: "4px" }}>{company._count?.departments || 0}</div>
                </div>
                <div>
                  <div style={{ fontSize: "0.65rem", color: "var(--text-muted)", textTransform: "uppercase", fontWeight: "600" }}>Events</div>
                  <div style={{ color: "#fff", fontWeight: "700", marginTop: "4px" }}>{company._count?.challenges || 0}</div>
                </div>
              </div>
            </div>
          </div>
        )) : (
          <div style={{ gridColumn: "1/-1", textAlign: "center", color: "var(--text-muted)", padding: "48px", fontWeight: "500" }}>No B2B clients found.</div>
        )}
      </div>

      {showModal && (
        <div className="modal-backdrop">
          <div className="modal-dialog">
            <h4 className="modal-title">Onboard New Enterprise</h4>
            <form onSubmit={handleSubmit} className="modal-form">
              <input type="text" placeholder="Company Name" required value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="search-input" style={{ padding: "14px 16px" }} />
              <input type="text" placeholder="Email Domain (e.g. google.com)" value={form.domain} onChange={e => setForm({...form, domain: e.target.value})} className="search-input" style={{ padding: "14px 16px" }} />
              <div style={{ display: "flex", gap: "12px", marginTop: "12px" }}>
                <button type="button" onClick={() => setShowModal(false)} className="btn btn-secondary flex-1" style={{ padding: "12px" }}>Cancel</button>
                <button type="submit" className="btn btn-primary flex-1" style={{ padding: "12px" }}>Provision License</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
