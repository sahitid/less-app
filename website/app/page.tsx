import { PhoneShowcase, Reveal, WordReveal } from "./scroll";
import { WaitlistButton } from "./waitlist";

// CSS-drawn stand-ins shown if the screenshot files aren't in the deployment.
function HomeMock({ paper = false }: { paper?: boolean }) {
  const bg = paper ? "bg-[#f7f5f0] text-[#121214]" : "bg-black text-white";
  const card = paper ? "bg-white" : "bg-neutral-900";
  const sub = paper ? "text-neutral-500" : "text-neutral-400";
  return (
    <div className={`flex h-full w-full flex-col gap-3 p-4 pt-8 text-left ${bg}`}>
      <div className="text-lg font-semibold">&lt;</div>
      <div className="text-xl font-semibold leading-none">Less</div>
      <div className={`text-[9px] ${sub}`}>Scroll less. Live more.</div>
      <div className={`rounded-xl p-3 ${card}`}>
        <div className={paper ? "text-green-800" : "text-green-200/80"}>
          <span className="text-lg font-light">0h 0m</span>
        </div>
        <div className={`text-[8px] ${sub}`}>reclaimed so far</div>
      </div>
      <div className={`flex-1 rounded-xl p-3 text-[11px] leading-relaxed ${card}`}>
        {["Phone", "Messages", "Maps", "Camera", "Notes", "Music"].map((n) => (
          <div key={n} className="py-0.5">{n}</div>
        ))}
      </div>
    </div>
  );
}

function BreatheMock() {
  return (
    <div className="flex h-full w-full flex-col items-center justify-center gap-6 bg-black text-white">
      <div className="text-xs font-light">Breathe out</div>
      <div className="h-24 w-24 rounded-full border border-green-200/70 bg-green-200/5" />
      <div className="text-[9px] text-neutral-500">3 breaths to go</div>
    </div>
  );
}

const slides = [
  {
    src: "/screens/home-widgets.jpg",
    alt: "iPhone home screen with the Less widget listing essential apps",
    title: "Only what you need.",
    body: "Two widgets replace your app grid with a plain text list of your essential apps. Everything else stays out of sight.",
    mock: <HomeMock />,
  },
  {
    src: "/screens/breathe.jpg",
    alt: "Breathing exercise before a distracting app opens",
    title: "Breathe before you scroll.",
    body: "Distracting apps open only after a guided breathing exercise. Just enough friction to ask: do I actually want this?",
    mock: <BreatheMock />,
  },
  {
    src: "/screens/home-ink.jpg",
    alt: "Less app showing time reclaimed and opens avoided",
    title: "Watch the time come back.",
    body: "Every pause you finish and every scroll you skip adds up. Less keeps score of the hours you take back.",
    mock: <HomeMock />,
  },
  {
    src: "/screens/home-paper.jpg",
    alt: "Less home screen in Paper theme",
    title: "Ink or Paper.",
    body: "White on black, or black on white. The app, the widgets, and your wallpaper stay in sync either way.",
    mock: <HomeMock paper />,
  },
];

function Mark({ className = "" }: { className?: string }) {
  return (
    <span
      className={`flex items-center justify-center rounded-[10px] bg-white font-semibold text-black ${className}`}
    >
      &lt;
    </span>
  );
}

function DownloadButton({ label }: { label: string }) {
  return (
    <WaitlistButton
      label={label}
      className="inline-block rounded-full bg-white px-8 py-4 text-base font-medium text-black transition hover:bg-neutral-200"
    />
  );
}

export default function Home() {
  return (
    <main>
      {/* Nav */}
      <header className="fixed inset-x-0 top-0 z-50 border-b border-white/5 bg-black/70 backdrop-blur">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-3">
            <Mark className="h-9 w-9 text-xl" />
            <span className="text-lg font-semibold tracking-tight">Less</span>
          </div>
          <WaitlistButton
            label="Download"
            className="rounded-full bg-white px-5 py-2 text-sm font-medium text-black transition hover:bg-neutral-200"
          />
        </div>
      </header>

      {/* Hero */}
      <section className="flex min-h-screen flex-col items-center justify-center px-6 pt-24 text-center">
        <Mark className="h-16 w-16 rounded-2xl text-4xl" />
        <h1 className="mt-10 text-5xl font-semibold leading-[1.05] tracking-tight sm:text-7xl">
          Your phone,
          <br />
          minus the noise.
        </h1>
        <p className="mx-auto mt-8 max-w-xl text-lg leading-relaxed text-neutral-400">
          Less turns your iPhone into a minimal dumbphone. A text-only home
          screen with the apps you need, and a deep breath before the ones you
          don&apos;t.
        </p>
        <div className="mt-10">
          <DownloadButton label="Join the waitlist" />
        </div>
        <p className="mt-4 text-sm text-neutral-600">
          Free · iPhone &amp; iPad · We&apos;ll email you when it&apos;s ready
        </p>
        <div className="mt-20 animate-bounce text-neutral-600">↓</div>
      </section>

      {/* Scroll statement, word by word */}
      <WordReveal text="Your home screen decides where your attention goes. Less makes that decision yours again." />

      {/* Sticky phone showcase */}
      <PhoneShowcase slides={slides} />

      {/* Setup steps */}
      <section className="mx-auto max-w-5xl px-6 py-28">
        <Reveal>
          <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">
            Set up in a minute.
          </h2>
        </Reveal>
        <ol className="mt-12 grid grid-cols-1 gap-10 sm:grid-cols-2">
          {[
            "Download Less and pick your essential apps.",
            "Add the Top and Bottom widgets to your Home Screen.",
            "Match your wallpaper and hide your other pages.",
            "That's it. Your phone is a tool again.",
          ].map((step, i) => (
            <Reveal key={step}>
              <li className="flex items-start gap-4">
                <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full border border-neutral-700 text-sm">
                  {i + 1}
                </span>
                <span className="leading-relaxed text-neutral-300">{step}</span>
              </li>
            </Reveal>
          ))}
        </ol>
      </section>

      {/* Final CTA */}
      <section className="border-t border-neutral-900 px-6 py-32 text-center">
        <Reveal>
          <p className="text-4xl font-semibold tracking-tight sm:text-6xl">
            Do less. Live more.
          </p>
          <div className="mt-10">
            <DownloadButton label="Join the waitlist" />
          </div>
        </Reveal>
      </section>

      <footer className="flex flex-col items-center gap-2 border-t border-neutral-900 px-6 py-10 text-center text-sm text-neutral-600">
        <span>
          Less,{" "}
          <a href="https://sahiti.dev" className="underline hover:text-neutral-400">
            a personal project
          </a>
          .
        </span>
        <span>
          Inspired by{" "}
          <a
            href="https://www.blankspaces.app/"
            className="underline hover:text-neutral-400"
          >
            blankspaces.app
          </a>
          . Not affiliated with Ecstasis LLC.
        </span>
      </footer>
    </main>
  );
}
