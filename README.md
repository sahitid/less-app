# Less — a minimalist launcher (Blank Spaces recreation)

A from-scratch recreation of [Blank Spaces](https://www.blankspaces.app/) — the minimalist
"dumbphone" launcher for iPhone. Built with SwiftUI + WidgetKit. Not affiliated with Ecstasis LLC;
for personal/educational use.

## How it works

Blank Spaces doesn't replace the iOS home screen (iOS doesn't allow that). Instead:

1. **Two home-screen widgets** — a medium **Top** widget and a large **Bottom** widget — render
   your chosen apps as a plain white-on-black text list, filling the whole screen.
2. Tapping an app name deep-links through the main app (`blankspaces://launch?scheme=...`),
   which immediately relaunches the target app via its URL scheme.
3. Apps you flag as **distractions** (Instagram, TikTok, …) don't open right away — you get a
   guided **breathing exercise** first, then a choice: *Open* or *Never mind — reclaim my time*.
4. The home screen tracks pauses taken, opens avoided, and estimated time reclaimed.
5. You hide your regular app pages (Home Screen → edit pages → uncheck), leaving only the
   widget page. The in-app **widget tutorial** recreates blankspaces.app/widgets-tutorial.

## Project layout

| Path | What |
|---|---|
| `BlankSpaces/` | Main SwiftUI app (onboarding, home, app picker, breathing gate, wallpaper matcher, tutorial, settings) |
| `BlankWidgets/` | WidgetKit extension (Top = medium, Bottom = large), theme-aware |
| `Shared/` | Models, URL-scheme catalog, App Group persistence, design system — compiled into both targets |
| `Config/` | Info.plists and entitlements for both targets |

## Themes & wallpaper matching

Two themes, selectable in Settings: **Ink** (white-on-black) and **Paper** (black-on-white).
The app, both widgets, and the wallpaper recommendation follow the same theme so the home
screen reads as one seamless surface. iOS has no API to set wallpaper, so the
**Match your wallpaper** screen walks through Settings → Wallpaper → Add New Wallpaper →
Color → Solid, and can save a pixel-matched solid image to Photos
(`NSPhotoLibraryAddUsageDescription`, add-only access) as an alternative.

The UI uses a shared design system (`Shared/DesignSystem.swift`): an 8pt spacing scale and a
monochrome base with three muted accents — sage (progress), amber (friction), mist (info).

## Building

Requires **Xcode 16+** (the project uses folder-synced groups). This machine only had Command
Line Tools when the project was generated, so it hasn't been compiled yet — install Xcode from
the App Store first.

1. Open `BlankSpaces.xcodeproj`.
2. Select your team under *Signing & Capabilities* for **both** targets.
3. If Xcode complains about the App Group with your team, rename
   `group.com.sahiti.less` to something unique in **both** `.entitlements` files **and**
   in `Shared/SharedModels.swift` (`BlankSpacesConfig.appGroupID`). Same for the bundle IDs.
4. Run the **BlankSpaces** scheme on a device or simulator.
5. On the device: long-press the home screen → **+** → search "Blank" → add the medium **Top**
   and large **Bottom** widgets → hide your other pages.

If the .xcodeproj ever gets mangled, regenerate it: `brew install xcodegen && xcodegen`.

## Notes & limitations

- iOS apps can't enumerate installed apps, so the picker offers a curated catalog of known
  URL schemes plus a custom-scheme option. Apps without a URL scheme (e.g. the system Camera
  has no official one) may not launch — the `camera://` entry works on most iOS versions but
  isn't guaranteed.
- The real app's hard blocking uses Apple's Screen Time / FamilyControls entitlement, which
  requires Apple's approval. This recreation implements friction (the breathing gate) inside
  the launcher flow instead — same effect for widget-launched apps, but it can't stop you from
  opening an app from Spotlight or the App Library.
- Widget taps always bounce through the main app for a moment; that's how the original works
  too (widgets can only deep-link into their own app).
