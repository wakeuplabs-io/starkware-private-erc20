import { useCopyToClipboard } from "@/hooks/useCopy";
import { shortenAddress } from "@/lib/utils";
import { AccountService } from "@/services/account.service";
import { CopyCheckIcon, CopyIcon } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import QRCode from "react-qr-code";

export const Receive: React.FC = () => {
  const [qrValue, setQrValue] = useState("");

  useEffect(() => {
    AccountService.getAccount().then((account) => {
      setQrValue(
        JSON.stringify({
          address: account.address.toString(),
          publicKey: account.publicKey.toString(),
        })
      );
    });
  }, [qrValue]);

  return (
    <div className="flex flex-col p-12 bg-white rounded-3xl border border-primary">
      <div className="flex flex-col items-center mb-12">
        <QRCode
        //   size={215}
          style={{ height: "auto",  width: "100%" }}
          value={qrValue}
          viewBox={`0 0 256 256`}
        />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <AddressField
          value={"0xA759dD38ec330c9251C705F35DE812666c031E9f"}
          label={"Address"}
        />
        <AddressField
          value={"0xA759dD38ec330c9251C705F35DE812666c031E9f"}
          label={"Public key"}
        />
      </div>
    </div>
  );
};

const AddressField: React.FC<{ value: string; label: string }> = ({
  value,
  label,
}) => {
  const { copyToClipboard, isCopied } = useCopyToClipboard({ timeout: 2000 });

  return (
    <button
      onClick={() => copyToClipboard(value)}
      disabled={isCopied}
      className="flex gap-2 items-start justify-center text-muted-foreground bg-transparent"
    >
      {isCopied ? (
        <CopyCheckIcon className="h-5 w-5 m-1" />
      ) : (
        <CopyIcon className="h-5 w-5 m-1" />
      )}
      <div className="text-left">
        <div className="text-sm">{shortenAddress(value)}</div>
        <div className="text-xs">{label}</div>
      </div>
    </button>
  );
};
