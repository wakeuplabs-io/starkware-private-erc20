import { useApprove } from "@/hooks/useApprove";
import { useCallback, useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { QrCode } from "lucide-react";
import { IDetectedBarcode, Scanner } from "@yudiel/react-qr-scanner";
import { AccountService } from "@/services/account.service";
import { BarretenbergService } from "@/services/bb.service";
import { Fr } from "@aztec/bb.js";
import { formatHex } from "@/lib/utils";

export const Approve: React.FC = () => {
  const { sendApprove, loading } = useApprove();
  const [spenderAddress, setSpenderAddress] = useState("");
  const [spenderPublicKey, setSpenderPublicKey] = useState("");
  const [amount, setAmount] = useState("0");
  const [scan, setScan] = useState(false);

  
  const onApprove = useCallback(async () => {
    const approverAccount = await AccountService.getAccount();

    const outRelationshipId = await BarretenbergService.generateHashArray([
      new Fr(approverAccount.address),
      new Fr(BigInt(spenderAddress)),
    ]);
    console.log({
      approverAddress: approverAccount.address,
      spenderAddress: spenderAddress,
      outRelationshipId: formatHex(outRelationshipId),
    });
    sendApprove({
      spender: {
        address: BigInt(spenderAddress),
        publicKey: BigInt(spenderPublicKey),
      },
      amount: BigInt((parseFloat(amount) * 10 ** 6).toFixed(0)),
    })
      .then(() => {
        window.alert("Approval successful");
      })
      .catch((error) => {
        console.error(error);
        window.alert("Approval failed");
      });
  }, [amount, spenderAddress, spenderPublicKey, sendApprove]);

  const onScan = useCallback((result: IDetectedBarcode[]) => {
    const data = JSON.parse(result[0].rawValue);
    setSpenderAddress(data.spender.startsWith("0x") ? data.spender : `0x${data.spender}`);
    setSpenderPublicKey(data.publicKey.startsWith("0x") ? data.publicKey : `0x${data.publicKey}`);
    setScan(false);
  }, [setSpenderAddress, setSpenderPublicKey, setScan]);

  return (
    <div className="flex flex-col p-6 bg-white rounded-3xl border border-primary">
      <div className="flex items-center justify-between mb-6">
        <h1 className="font-semibold">Approve</h1>
        <Button onClick={() => setScan(!scan)} size="icon">
          <QrCode />
        </Button>
      </div>

      {scan ? (
        <div>
          <Scanner onScan={onScan} />
        </div>
      ) : (
        <>
          <div className="space-y-4 mb-12">
            <Input
              type="text"
              placeholder="Spender Address"
              value={spenderAddress}
              onChange={(e) => setSpenderAddress(e.target.value)}
            />

            <Input
              type="text"
              placeholder="Spender Public Key"
              value={spenderPublicKey}
              onChange={(e) => setSpenderPublicKey(e.target.value)}
            />

            <Input
              type="text"
              placeholder="Amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />
          </div>

          <Button className="w-full" onClick={onApprove} disabled={loading}>
            {loading ? "Approving..." : "Approve"}
          </Button>
        </>
      )}
    </div>
  );
};
