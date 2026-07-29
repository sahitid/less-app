import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Less — turn your iPhone into a dumbphone",
  description:
    "Less replaces your app grid with a calm, text-only home screen. Fewer apps, a breathing exercise before the distracting ones, and your time back.",
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
