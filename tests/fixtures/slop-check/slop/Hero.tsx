export function Hero() {
  return (
    <section>
      <p className="text-xs uppercase tracking-widest text-indigo-500">Features</p>
      <h2 className="bg-clip-text text-transparent bg-gradient-to-r from-purple-500 to-blue-500">Everything you need</h2>
      <button className="rounded-lg border shadow-md px-4">Get started 🚀</button>
      <Sparkles className="h-4 w-4" />
      <div className="rounded-xl border p-6">
        <div className="rounded-lg border p-4">Inner</div>
      </div>
      <ul>
        <li>10x faster</li>
        <li>99.9% uptime</li>
        <li>10,000+ teams</li>
      </ul>
    </section>
  );
}
