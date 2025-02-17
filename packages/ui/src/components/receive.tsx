import { useAccount } from "@/hooks/use-account";
import { useCopyToClipboard } from "@/hooks/use-copy";
import { formatHex, shortenString } from "@/lib/utils";
import { CopyCheckIcon, CopyIcon } from "lucide-react";
import { useMemo } from "react";
import QRCode from "react-qr-code";

export const Receive: React.FC = () => {
  const { account } = useAccount();

  const qrValue = useMemo(() => {
    if (!account) return "";

    return JSON.stringify({
      address: formatHex(account.owner.address),
      publicKey: formatHex(account.viewer.publicKey),
    });
  }, [account]);

  return (
    <div className="flex flex-col p-14 md:flex-row md:justify-evenly md:items-center bg-white border-gradient rounded-3xl">
      <div className="flex justify-center mb-12 md:mb-0">
        <QRCode
          size={230}
          style={{ height: "auto", maxWidth: "215px", width: "100%" }}
          fgColor="#1C1B78"

          value={qrValue}
          viewBox={"0 0 256 256"}
        />
      </div>

      <div className="flex gap-4 justify-center md:flex-col md:gap-9">
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
