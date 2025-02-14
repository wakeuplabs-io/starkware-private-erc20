import { useCopyToClipboard } from "@/hooks/use-copy";
import { Account } from "@/interfaces";
import { formatHex, shortenString } from "@/lib/utils";
import { AccountService } from "@/services/account.service";
import { CopyCheckIcon, CopyIcon } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import QRCode from "react-qr-code";

export const Receive: React.FC = () => {
  const [account, setAccount] = useState<Account | null>(null);

  useEffect(() => {
    AccountService.getAccount().then((account) => {
      setAccount(account);
    });
  }, []);

  const qrValue = useMemo(() => {
    if (!account) return "";

    return JSON.stringify({
      address: formatHex(account.owner.address),
      publicKey: formatHex(account.viewer.publicKey),
    });
  }, [account]);

  return (
    <div className="flex flex-col p-12 bg-white rounded-3xl border border-primary">
      <div className="flex flex-col items-center mb-12">
        <QRCode
          size={215}
          style={{ height: "auto", maxWidth: "215px", width: "100%" }}
          value={qrValue}
          viewBox={`0 0 256 256`}
        />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <AddressField
          value={formatHex(account?.owner.address ?? 0n)}
          label={"Address"}
        />
        <AddressField
          value={formatHex(account?.viewer.publicKey ?? 0n)}
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
        <div className="text-sm">{shortenString(value)}</div>
        <div className="text-xs">{label}</div>
      </div>
    </button>
  );
};
