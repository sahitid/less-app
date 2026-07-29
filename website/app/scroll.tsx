"use client";

import { useEffect, useRef, useState } from "react";

/** Scroll progress (0..1) of a tall wrapper whose content is sticky. */
function useScrollProgress(ref: React.RefObject<HTMLElement | null>) {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    let raf = 0;
    const onScroll = () => {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(() => {
        const rect = el.getBoundingClientRect();
        const total = rect.height - window.innerHeight;
        const passed = Math.min(Math.max(-rect.top, 0), total);
        setProgress(total > 0 ? passed / total : 0);
      });
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
    };
  }, [ref]);

  return progress;
}

/**
 * Blank Spaces-style statement reveal: a giant sentence whose words light up
 * one by one as you scroll through a tall sticky section.
 */
export function WordReveal({ text }: { text: string }) {
  const wrapRef = useRef<HTMLDivElement>(null);
  const progress = useScrollProgress(wrapRef);
  const words = text.split(" ");

  return (
    <div ref={wrapRef} className="relative h-[220vh]">
      <div className="sticky top-0 flex h-screen items-center">
        <p className="mx-auto max-w-4xl px-6 text-center text-4xl font-semibold leading-[1.15] tracking-tight sm:text-6xl md:text-7xl">
          {words.map((word, i) => {
            const lit = progress * words.length > i;
            return (
              <span
                key={i}
                className="transition-colors duration-300"
                style={{ color: lit ? "#fff" : "rgba(255,255,255,0.14)" }}
              >
                {word}{" "}
              </span>
            );
          })}
        </p>
      </div>
    </div>
  );
}

type Slide = { src: string; alt: string; title: string; body: string; mock: React.ReactNode };

/**
 * Shows the real screenshot when /screens/*.jpg exists in the deployment;
 * falls back to a CSS-drawn mock of the same screen when it doesn't.
 */
function PhoneShot({ slide, active }: { slide: Slide; active: boolean }) {
  const [failed, setFailed] = useState(false);

  return (
    <div
      className={`absolute inset-0 transition-opacity duration-500 ${
        active ? "opacity-100" : "opacity-0"
      }`}
    >
      {failed ? (
        slide.mock
      ) : (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={slide.src}
          alt={slide.alt}
          className="h-full w-full object-cover"
          onError={() => setFailed(true)}
        />
      )}
    </div>
  );
}

/**
 * Sticky phone showcase: the phone stays pinned while scrolling swaps
 * the screenshot and caption, like the feature scroller on blankspaces.app.
 */
export function PhoneShowcase({ slides }: { slides: Slide[] }) {
  const wrapRef = useRef<HTMLDivElement>(null);
  const progress = useScrollProgress(wrapRef);
  const index = Math.min(
    slides.length - 1,
    Math.floor(progress * slides.length)
  );

  return (
    <div ref={wrapRef} className="relative" style={{ height: `${slides.length * 100 + 60}vh` }}>
      <div className="sticky top-0 flex h-screen flex-col items-center justify-center gap-8 px-6 md:flex-row md:gap-20">
        {/* Phone */}
        <div
          className="relative w-[210px] shrink-0 overflow-hidden rounded-[2.2rem] border border-neutral-800 sm:w-[250px]"
          style={{ aspectRatio: "358 / 780" }}
        >
          {slides.map((slide, i) => (
            <PhoneShot key={slide.src} slide={slide} active={i === index} />
          ))}
        </div>

        {/* Caption */}
        <div className="max-w-sm text-center md:text-left">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-neutral-600">
            {index + 1} / {slides.length}
          </p>
          <h3 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">
            {slides[index].title}
          </h3>
          <p className="mt-4 text-base leading-relaxed text-neutral-400 sm:text-lg">
            {slides[index].body}
          </p>
          <div className="mt-8 flex justify-center gap-2 md:justify-start">
            {slides.map((_, i) => (
              <span
                key={i}
                className="h-1 rounded-full transition-all duration-300"
                style={{
                  width: i === index ? 28 : 10,
                  background: i === index ? "#fff" : "rgba(255,255,255,0.2)",
                }}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

/** Fades content up as it enters the viewport. */
export function Reveal({ children }: { children: React.ReactNode }) {
  const ref = useRef<HTMLDivElement>(null);
  const [shown, setShown] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      ([entry]) => entry.isIntersecting && setShown(true),
      { threshold: 0.2 }
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);

  return (
    <div
      ref={ref}
      className="transition-all duration-700 ease-out"
      style={{
        opacity: shown ? 1 : 0,
        transform: shown ? "translateY(0)" : "translateY(28px)",
      }}
    >
      {children}
    </div>
  );
}
