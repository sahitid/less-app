import SwiftUI
import WidgetKit

@main
struct BlankSpacesApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.theme == .black ? .dark : .light)
                .onOpenURL { url in
                    store.handleDeepLink(url)
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        ZStack {
            store.palette.background.ignoresSafeArea()

            if hasOnboarded {
                HomeView()
            } else {
                OnboardingView(onFinish: { hasOnboarded = true })
            }
        }
        .fullScreenCover(item: $store.pendingApp) { app in
            BreathingGateView(app: app)
                .environmentObject(store)
        }
    }
}

// MARK: - App state

@MainActor
final class AppStore: ObservableObject {
    @Published var apps: [LaunchableApp] = SharedStore.loadApps() {
        didSet {
            SharedStore.saveApps(apps)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var stats: UsageStats = SharedStore.loadStats() {
        didSet { SharedStore.saveStats(stats) }
    }

    @Published var theme: BlankTheme = SharedStore.theme {
        didSet {
            SharedStore.theme = theme
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var wallpaperDone: Bool = SharedStore.wallpaperDone {
        didSet { SharedStore.wallpaperDone = wallpaperDone }
    }

    /// Set when a blocked app is waiting behind the breathing gate.
    @Published var pendingApp: LaunchableApp?

    var palette: Palette { Palette.forTheme(theme) }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == BlankSpacesConfig.urlScheme,
              url.host == "launch",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.queryItems?.first(where: { $0.name == "scheme" })?.value
        else { return }

        let app = apps.first(where: { $0.scheme == scheme })
            ?? AppCatalog.all.first(where: { $0.scheme == scheme })
            ?? LaunchableApp(name: "App", scheme: scheme)

        if app.isBlocked {
            pendingApp = app
        } else {
            open(app)
        }
    }

    func open(_ app: LaunchableApp) {
        guard let url = app.targetURL else { return }
        UIApplication.shared.open(url)
    }

    func isSelected(_ app: LaunchableApp) -> Bool {
        apps.contains(where: { $0.scheme == app.scheme })
    }

    func toggle(_ app: LaunchableApp) {
        if let index = apps.firstIndex(where: { $0.scheme == app.scheme }) {
            apps.remove(at: index)
        } else {
            apps.append(app)
        }
    }

    func setBlocked(_ blocked: Bool, for app: LaunchableApp) {
        guard let index = apps.firstIndex(where: { $0.scheme == app.scheme }) else { return }
        apps[index].isBlocked = blocked
    }
}
