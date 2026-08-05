"use client";

import { useEffect, useState } from "react";

type Status = "idle" | "sending" | "done" | "error";

function WaitlistModal({ onClose }: { onClose: () => void }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [company, setCompany] = useState(""); // honeypot
  const [status, setStatus] = useState<Status>("idle");
  const [error, setError] = useState("");

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      window.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [onClose]);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("sending");
    setError("");
    try {
      const res = await fetch("/api/waitlist", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ name, email, company }),
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error ?? "Something went wrong. Try again?");
        setStatus("error");
        return;
      }
      setStatus("done");
    } catch {
      setError("Something went wrong. Try again?");
      setStatus("error");
    }
  }

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 px-6 backdrop-blur-sm"
      onClick={onClose}
    >
      <div
        className="w-full max-w-md rounded-3xl border border-neutral-800 bg-neutral-950 p-8"
        onClick={(e) => e.stopPropagation()}
      >
        {status === "done" ? (
          <div className="text-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/mark.png"
              alt="Less logo"
              className="mx-auto h-12 w-12 rounded-xl border border-neutral-800"
            />
            <h3 className="mt-6 text-2xl font-semibold tracking-tight">
              You&apos;re on the list.
            </h3>
            <p className="mt-3 text-neutral-400">
              We&apos;ll keep you posted as Less evolves. Can&apos;t wait?{" "}
              <a
                href="https://testflight.apple.com/join/YVtm12EW"
                className="text-white underline hover:text-neutral-300"
              >
                Get the beta now
              </a>
              .
            </p>
            <button
              onClick={onClose}
              className="mt-8 rounded-full bg-white px-8 py-3 text-sm font-medium text-black transition hover:bg-neutral-200"
            >
              Done
            </button>
          </div>
        ) : (
          <>
            <h3 className="text-2xl font-semibold tracking-tight">
              Stay in the loop
            </h3>
            <p className="mt-2 text-sm text-neutral-400">
              Leave your email for updates on new features and the App Store
              launch.
            </p>
            <form onSubmit={submit} className="mt-6 flex flex-col gap-3">
              <input
                type="text"
                required
                placeholder="Your name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="rounded-xl border border-neutral-800 bg-black px-4 py-3 text-white placeholder-neutral-600 outline-none transition focus:border-neutral-500"
              />
              <input
                type="email"
                required
                placeholder="you@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="rounded-xl border border-neutral-800 bg-black px-4 py-3 text-white placeholder-neutral-600 outline-none transition focus:border-neutral-500"
              />
              {/* Honeypot — hidden from real users */}
              <input
                type="text"
                tabIndex={-1}
                autoComplete="off"
                value={company}
                onChange={(e) => setCompany(e.target.value)}
                className="absolute -left-[9999px] h-0 w-0 opacity-0"
                aria-hidden="true"
              />
              {error && <p className="text-sm text-red-400">{error}</p>}
              <button
                type="submit"
                disabled={status === "sending"}
                className="mt-2 rounded-full bg-white px-8 py-3.5 text-base font-medium text-black transition hover:bg-neutral-200 disabled:opacity-60"
              >
                {status === "sending" ? "Joining…" : "Join the waitlist"}
              </button>
              <button
                type="button"
                onClick={onClose}
                className="py-1 text-sm text-neutral-500 transition hover:text-neutral-300"
              >
                Cancel
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

export function WaitlistButton({
  label,
  className,
}: {
  label: string;
  className: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button onClick={() => setOpen(true)} className={className}>
        {label}
      </button>
      {open && <WaitlistModal onClose={() => setOpen(false)} />}
    </>
  );
}
