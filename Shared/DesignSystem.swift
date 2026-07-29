import SwiftUI

// MARK: - Spacing scale (8pt grid)

enum Space {
    /// 4 — hairline gaps
    static let xxs: CGFloat = 4
    /// 8 — within a cluster
    static let xs: CGFloat = 8
    /// 12 — tight rows
    static let sm: CGFloat = 12
    /// 16 — default gap
    static let md: CGFloat = 16
    /// 24 — card padding, gaps between clusters
    static let lg: CGFloat = 24
    /// 32 — between sections
    static let xl: CGFloat = 32
    /// 48 — page-level breathing room
    static let xxl: CGFloat = 48
}

// MARK: - Palette

/// Theme-derived colors. Monochrome base (so widgets vanish into the wallpaper)
/// with two muted accents: sage for progress, amber for friction.
struct Palette {
    let background: Color
    let surface: Color
    let surfaceRaised: Color
    let hairline: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    /// Progress, stats, "time reclaimed" — calm green.
    let sage: Color
    /// Friction, gated apps, breathing — warm amber.
    let amber: Color
    /// Informational touches — dusty blue.
    let mist: Color

    static let ink = Palette(
        background: .black,
        surface: Color(red: 0.09, green: 0.09, blue: 0.10),
        surfaceRaised: Color(red: 0.13, green: 0.13, blue: 0.15),
        hairline: Color.white.opacity(0.10),
        textPrimary: .white,
        textSecondary: Color(red: 0.62, green: 0.62, blue: 0.64),
        textTertiary: Color(red: 0.38, green: 0.38, blue: 0.40),
        sage: Color(red: 0.66, green: 0.76, blue: 0.61),
        amber: Color(red: 0.89, green: 0.72, blue: 0.44),
        mist: Color(red: 0.58, green: 0.68, blue: 0.78)
    )

    static let paper = Palette(
        background: Color(red: 0.97, green: 0.96, blue: 0.94),
        surface: .white,
        surfaceRaised: Color(red: 0.93, green: 0.92, blue: 0.90),
        hairline: Color.black.opacity(0.08),
        textPrimary: Color(red: 0.07, green: 0.07, blue: 0.08),
        textSecondary: Color(red: 0.42, green: 0.42, blue: 0.44),
        textTertiary: Color(red: 0.64, green: 0.64, blue: 0.66),
        sage: Color(red: 0.33, green: 0.45, blue: 0.29),
        amber: Color(red: 0.66, green: 0.48, blue: 0.16),
        mist: Color(red: 0.30, green: 0.42, blue: 0.54)
    )

    static func forTheme(_ theme: BlankTheme) -> Palette {
        theme == .black ? .ink : .paper
    }
}
