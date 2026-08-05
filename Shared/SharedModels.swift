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
    static let gateHistoryKey = "gateHistory"
    static let sessionMinutesKey = "sessionMinutes"

    /// Reopening a gated app within this window costs extra breaths.
    static let reopenWindow: TimeInterval = 30 * 60
    /// Hard ceiling on breaths, however often an app is reopened.
    static let maxBreaths = 8
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

struct WeekStats: Codable {
    var pauses: Int = 0
    var avoided: Int = 0
}

struct UsageStats: Codable {
    var pausesCompleted: Int = 0
    var opensAvoided: Int = 0
    /// Tap counts for the post-breath intention prompt ("Reply", "Just bored", …).
    var intents: [String: Int] = [:]
    /// Consecutive days with at least one pause or avoided open.
    var streakDays: Int = 0
    var lastActiveDay: Date? = nil
    /// Per-week totals keyed by the week's start date (yyyy-MM-dd), kept for ~8 weeks.
    var weekly: [String: WeekStats] = [:]

    /// Rough estimate shown on the home screen: every avoided open ≈ 12 minutes not lost.
    var minutesReclaimed: Int { opensAvoided * 12 }

    init() {}

    // Manual decoding so stats saved by build 1 (only the first two fields) still load.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        pausesCompleted = try c.decodeIfPresent(Int.self, forKey: .pausesCompleted) ?? 0
        opensAvoided = try c.decodeIfPresent(Int.self, forKey: .opensAvoided) ?? 0
        intents = try c.decodeIfPresent([String: Int].self, forKey: .intents) ?? [:]
        streakDays = try c.decodeIfPresent(Int.self, forKey: .streakDays) ?? 0
        lastActiveDay = try c.decodeIfPresent(Date.self, forKey: .lastActiveDay)
        weekly = try c.decodeIfPresent([String: WeekStats].self, forKey: .weekly) ?? [:]
    }

    // MARK: Recording

    mutating func recordPauseCompleted() {
        pausesCompleted += 1
        currentWeek { $0.pauses += 1 }
        touchStreak()
    }

    mutating func recordOpenAvoided() {
        opensAvoided += 1
        currentWeek { $0.avoided += 1 }
        touchStreak()
    }

    mutating func recordIntent(_ intent: String) {
        intents[intent, default: 0] += 1
    }

    private mutating func touchStreak() {
        let today = Calendar.current.startOfDay(for: .now)
        if let last = lastActiveDay {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay == today { return }
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
            streakDays = lastDay == yesterday ? streakDays + 1 : 1
        } else {
            streakDays = 1
        }
        lastActiveDay = today
    }

    private mutating func currentWeek(_ update: (inout WeekStats) -> Void) {
        let key = Self.weekKey(for: .now)
        var week = weekly[key] ?? WeekStats()
        update(&week)
        weekly[key] = week
        if weekly.count > 8 {
            for stale in weekly.keys.sorted().dropLast(8) { weekly.removeValue(forKey: stale) }
        }
    }

    // MARK: Weekly review

    static func weekKey(for date: Date) -> String {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = calendar.timeZone
        return f.string(from: start)
    }

    var thisWeek: WeekStats { weekly[Self.weekKey(for: .now)] ?? WeekStats() }

    var lastWeek: WeekStats {
        guard let aWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now)
        else { return WeekStats() }
        return weekly[Self.weekKey(for: aWeekAgo)] ?? WeekStats()
    }
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

    /// Last session length (minutes) picked in the breathing gate.
    static var sessionMinutes: Int {
        get {
            let value = defaults.integer(forKey: BlankSpacesConfig.sessionMinutesKey)
            return value == 0 ? 10 : value
        }
        set { defaults.set(newValue, forKey: BlankSpacesConfig.sessionMinutesKey) }
    }

    // MARK: Escalating friction

    struct GateRecord: Codable {
        var lastShown: Date
        var reopens: Int
    }

    static func loadGateHistory() -> [String: GateRecord] {
        guard let data = defaults.data(forKey: BlankSpacesConfig.gateHistoryKey),
              let history = try? JSONDecoder().decode([String: GateRecord].self, from: data)
        else { return [:] }
        return history
    }

    static func saveGateHistory(_ history: [String: GateRecord]) {
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: BlankSpacesConfig.gateHistoryKey)
        }
    }

    /// Extra breaths owed for reopening `scheme` within the reopen window: +2 per reopen.
    /// The total (base + extra) is capped at `BlankSpacesConfig.maxBreaths` by the caller.
    static func escalationBreaths(for scheme: String) -> Int {
        guard let record = loadGateHistory()[scheme],
              Date.now.timeIntervalSince(record.lastShown) < BlankSpacesConfig.reopenWindow
        else { return 0 }
        return record.reopens * 2
    }

    /// Call when the gate is shown so the next reopen inside the window costs more.
    static func noteGateShown(for scheme: String) {
        var history = loadGateHistory()
        if let record = history[scheme],
           Date.now.timeIntervalSince(record.lastShown) < BlankSpacesConfig.reopenWindow {
            history[scheme] = GateRecord(lastShown: .now, reopens: record.reopens + 1)
        } else {
            history[scheme] = GateRecord(lastShown: .now, reopens: 1)
        }
        // Drop stale entries so the blob stays tiny.
        history = history.filter { Date.now.timeIntervalSince($0.value.lastShown) < BlankSpacesConfig.reopenWindow * 4 }
        saveGateHistory(history)
    }
}
