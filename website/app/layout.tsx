import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://getless.vercel.app"),
  title: "Less — turn your iPhone into a dumbphone",
  description:
    "Less replaces your app grid with a calm, text-only home screen. Fewer apps, a breathing exercise before the distracting ones, and your time back.",
  openGraph: {
    title: "Less — turn your iPhone into a dumbphone",
    description:
      "A calm, text-only home screen with the apps you need, and a deep breath before the ones you don't.",
    url: "https://getless.vercel.app",
    siteName: "Less",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Less — turn your iPhone into a dumbphone",
    description:
      "A calm, text-only home screen with the apps you need, and a deep breath before the ones you don't.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
