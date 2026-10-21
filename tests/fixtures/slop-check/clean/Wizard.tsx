export function Wizard({ status }) {
  return (
    <div>
      <p className="text-xs uppercase tracking-wide">Step 2 of 4</p>
      <h2>Shipping address</h2>
      <span className="rounded-full bg-red-100 px-2 text-xs uppercase tracking-wide">Failed</span>
      <p>Invoice total and due date.</p>
      <div className="dropdown-menu border shadow-lg">Menu</div>
      <h3>Billing</h3>
      <p>Uptime last 30 days: {status.uptime}%</p>
    </div>
  );
}
