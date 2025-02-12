import { useState } from "react";
import Transfer from "../transfer/transfer";
import Approve from "../approve/approve";
import { Button } from "../ui/button";
import "./action-bar.css";

const ActionBar = () => {
  const [selectedAction, setSelectedAction] = useState<"transfer" | "approve">(
    "transfer"
  );

  return (
    <div className="action-bar">
      <div className="button-group">
        <Button
          className={`action-button ${selectedAction === "transfer" ? "active" : ""}`}
          onClick={() => setSelectedAction("transfer")}
        >
          Transfer
        </Button>
        <Button
          className={`action-button ${selectedAction === "approve" ? "active" : ""}`}
          onClick={() => setSelectedAction("approve")}
        >
          Approve
        </Button>
        {/* Se pueden agregar más botones como TransferFrom */}
      </div>

      <div className="action-content">
        {selectedAction === "transfer" && <Transfer />}
        {selectedAction === "approve" && <Approve />}
      </div>
    </div>
  );
};

export default ActionBar;
