interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {}

export function Button(props: ButtonProps) {
  return <button className="btn" {...props} />;
}
