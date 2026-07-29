import Foundation

// MARK: - Constants shared between the app and the widget extension

enum BlankSpacesConfig {
    /// App Group used to share the selected app list with the widgets.
    /// If you change the bundle identifier, update this (and both .entitlements files) to match.
    static let appGroupID = "group.com.sahiti.less"

    /// Custom URL scheme registered by the main app (Config/BlankSpaces-Info.plist).
    static let urlScheme = "less"

    static let selectedAppsKey = "selectedApps"
    static let statsKey = "stats"
    static let breathCountKey = "breathCount"
    static let themeKey = "theme"
    static let wallpaperDoneKey = "wallpaperDone"
}

// MARK: - Theme

/// The two "blank" looks. The widget, the app, and the recommended wallpaper
/// all follow this so the home screen reads as one seamless surface.
enum BlankTheme: String, Codable, CaseIterable, Identifiable {
    case black
    case white

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .black: "Ink"
        case .white: "Paper"
        }
    }
}

// MARK: - Model

struct LaunchableApp: Codable, Identifiable, Hashable {
    var id: String { scheme }
    var name: String
    var scheme: String
    /// When true, tapping this app in the widget routes through the breathing exercise first.
    var isBlocked: Bool

    init(name: String, scheme: String, isBlocked: Bool = false) {
        self.name = name
        self.scheme = scheme
        self.isBlocked = isBlocked
    }

    /// Deep link the widget uses to route the tap through the main app.
    var widgetURL: URL {
        var components = URLComponents()
        components.scheme = BlankSpacesConfig.urlScheme
        components.host = "launch"
        components.queryItems = [URLQueryItem(name: "scheme", value: scheme)]
        return components.url ?? URL(string: "\(BlankSpacesConfig.urlScheme)://launch")!
    }

    /// URL that actually opens the target app.
    var targetURL: URL? { URL(string: scheme) }
}

struct UsageStats: Codable {
    var pausesCompleted: Int = 0
    var opensAvoided: Int = 0

    /// Rough estimate shown on the home screen: every avoided open ≈ 12 minutes not lost.
    var minutesReclaimed: Int { opensAvoided * 12 }
}

// MARK: - Catalog of known URL schemes

enum AppCatalog {
    static let essentials: [LaunchableApp] = [
        .init(name: "Phone",     scheme: "tel:"),
        .init(name: "Messages",  scheme: "sms:"),
        .init(name: "Camera",    scheme: "camera://"),
        .init(name: "Mail",      scheme: "mailto:"),
        .init(name: "FaceTime",  scheme: "facetime://"),
        .init(name: "Maps",      scheme: "maps://"),
        .init(name: "Photos",    scheme: "photos-redirect://"),
        .init(name: "Notes",     scheme: "mobilenotes://"),
        .init(name: "Calendar",  scheme: "calshow://"),
        .init(name: "Reminders", scheme: "x-apple-reminderkit://"),
        .init(name: "Music",     scheme: "music://"),
        .init(name: "Podcasts",  scheme: "podcasts://"),
        .init(name: "Books",     scheme: "ibooks://"),
        .init(name: "Weather",   scheme: "weather://"),
        .init(name: "Wallet",    scheme: "shoebox://"),
        .init(name: "Health",    scheme: "x-apple-health://"),
        .init(name: "Safari",    scheme: "x-web-search://"),
        .init(name: "Settings",  scheme: "App-prefs://"),
    ]

    static let thirdParty: [LaunchableApp] = [
        .init(name: "WhatsApp",    scheme: "whatsapp://"),
        .init(name: "Telegram",    scheme: "tg://"),
        .init(name: "Signal",      scheme: "sgnl://"),
        .init(name: "Spotify",     scheme: "spotify://"),
        .init(name: "Slack",       scheme: "slack://"),
        .init(name: "Gmail",       scheme: "googlegmail://"),
        .init(name: "Google Maps", scheme: "comgooglemaps://"),
        .init(name: "Chrome",      scheme: "googlechrome://"),
        .init(name: "Uber",        scheme: "uber://"),
        .init(name: "Venmo",       scheme: "venmo://"),
    ]

    /// Apps most people are trying to escape — pre-flagged for the breathing gate.
    static let distractions: [LaunchableApp] = [
        .init(name: "Instagram", scheme: "instagram://", isBlocked: true),
        .init(name: "TikTok",    scheme: "tiktok://",    isBlocked: true),
        .init(name: "X",         scheme: "twitter://",   isBlocked: true),
        .init(name: "YouTube",   scheme: "youtube://",   isBlocked: true),
        .init(name: "Reddit",    scheme: "reddit://",    isBlocked: true),
        .init(name: "Snapchat",  scheme: "snapchat://",  isBlocked: true),
    ]

    static var all: [LaunchableApp] { essentials + thirdParty + distractions }

    static let defaultSelection: [LaunchableApp] = [
        .init(name: "Phone",    scheme: "tel:"),
        .init(name: "Messages", scheme: "sms:"),
        .init(name: "Maps",     scheme: "maps://"),
        .init(name: "Camera",   scheme: "camera://"),
        .init(name: "Notes",    scheme: "mobilenotes://"),
        .init(name: "Music",    scheme: "music://"),
    ]
}

// MARK: - Shared persistence (app group)

struct SharedStore {
    static var defaults: UserDefaults {
        UserDefaults(suiteName: BlankSpacesConfig.appGroupID) ?? .standard
    }

    static func loadApps() -> [LaunchableApp] {
        guard let data = defaults.data(forKey: BlankSpacesConfig.selectedAppsKey),
              let apps = try? JSONDecoder().decode([LaunchableApp].self, from: data)
        else { return AppCatalog.defaultSelection }
        return apps
    }

    static func saveApps(_ apps: [LaunchableApp]) {
        if let data = try? JSONEncoder().encode(apps) {
            defaults.set(data, forKey: BlankSpacesConfig.selectedAppsKey)
        }
    }

    static func loadStats() -> UsageStats {
        guard let data = defaults.data(forKey: BlankSpacesConfig.statsKey),
              let stats = try? JSONDecoder().decode(UsageStats.self, from: data)
        else { return UsageStats() }
        return stats
    }

    static func saveStats(_ stats: UsageStats) {
        if let data = try? JSONEncoder().encode(stats) {
            defaults.set(data, forKey: BlankSpacesConfig.statsKey)
        }
    }

    static var breathCount: Int {
        get {
            let value = defaults.integer(forKey: BlankSpacesConfig.breathCountKey)
            return value == 0 ? 3 : value
        }
        set { defaults.set(newValue, forKey: BlankSpacesConfig.breathCountKey) }
    }

    static var theme: BlankTheme {
        get {
            BlankTheme(rawValue: defaults.string(forKey: BlankSpacesConfig.themeKey) ?? "") ?? .black
        }
        set { defaults.set(newValue.rawValue, forKey: BlankSpacesConfig.themeKey) }
    }

    /// Whether the user has saved/applied a matching wallpaper (drives the home-screen nudge).
    static var wallpaperDone: Bool {
        get { defaults.bool(forKey: BlankSpacesConfig.wallpaperDoneKey) }
        set { defaults.set(newValue, forKey: BlankSpacesConfig.wallpaperDoneKey) }
    }
}
