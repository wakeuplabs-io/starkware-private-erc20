export const WakeUpLogo: React.FC<{ className?: string, imageClassName?: string }> = ({ className, imageClassName }) => {
  return (
    <a href="https://wakeuplabs.io/" target="_blank">
      <img
        src="/wakeup-powered.png"
        alt=""
        className={className}
      />
    </a>
  );
};
