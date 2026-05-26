import React from "react";
import { X } from "lucide-react";

interface ModalProps {
  isOpen: boolean;
  title: string;
  onClose: () => void;
  children: React.ReactNode;
}

export const Modal: React.FC<ModalProps> = ({ isOpen, title, onClose, children }) => {
  if (!isOpen) return null;

  return (
    <div className="modal-backdrop">
      <div className="modal-dialog">
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "24px", borderBottom: "1px solid var(--border-color)", paddingBottom: "16px" }}>
          <h4 className="modal-title" style={{ marginBottom: 0 }}>
            {title}
          </h4>
          <button 
            onClick={onClose}
            className="btn-icon"
            style={{ padding: "6px", border: "none" }}
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        <div>
          {children}
        </div>
      </div>
    </div>
  );
};
