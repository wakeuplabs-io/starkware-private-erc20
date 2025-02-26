export const WakeUpLogo: React.FC<{ className?: string }> = ({ className }) => {
  return (
    <a href="https://wakeuplabs.io/" target="_blank">
      <img
        src="/wakeup-powered.png"
        alt="Wakeup logo"
        className={className}
      />
    </a>
  );
};
