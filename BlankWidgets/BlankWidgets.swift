import WidgetKit
import SwiftUI

// MARK: - Timeline

struct BlankEntry: TimelineEntry {
    let date: Date
    let apps: [LaunchableApp]
    let theme: BlankTheme
}

struct BlankProvider: TimelineProvider {
    func placeholder(in context: Context) -> BlankEntry {
        BlankEntry(date: .now, apps: AppCatalog.defaultSelection, theme: .black)
    }

    func getSnapshot(in context: Context, completion: @escaping (BlankEntry) -> Void) {
        completion(BlankEntry(date: .now, apps: SharedStore.loadApps(), theme: SharedStore.theme))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BlankEntry>) -> Void) {
        let entry = BlankEntry(date: .now, apps: SharedStore.loadApps(), theme: SharedStore.theme)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

// MARK: - Theme colors (must match the wallpaper the app recommends)

extension BlankEntry {
    var backgroundColor: Color {
        theme == .black ? .black : Color(red: 0.97, green: 0.96, blue: 0.94)
    }
    var textColor: Color {
        theme == .black ? .white : Color(red: 0.07, green: 0.07, blue: 0.08)
    }
    var secondaryColor: Color {
        theme == .black ? Color(white: 0.45) : Color(white: 0.55)
    }
}

// MARK: - Shared row

struct AppRow: View {
    let app: LaunchableApp
    let color: Color
    var fontSize: CGFloat = 21

    var body: some View {
        Link(destination: app.widgetURL) {
            Text(app.name)
                .font(.system(size: fontSize, weight: .regular))
                .foregroundStyle(color)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Top widget (medium) — first four apps

struct BlankTopWidgetView: View {
    let entry: BlankEntry

    var body: some View {
        Group {
            if entry.apps.isEmpty {
                Text("Open Less to\nchoose your apps")
                    .font(.system(size: 15))
                    .foregroundStyle(entry.secondaryColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
            } else {
                // Rows share the height equally, so 1–4 apps always fill the widget evenly.
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(entry.apps.prefix(4)) { app in
                        AppRow(app: app, color: entry.textColor)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .containerBackground(entry.backgroundColor, for: .widget)
    }
}

struct BlankTopWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BlankTopWidget", provider: BlankProvider()) { entry in
            BlankTopWidgetView(entry: entry)
        }
        .configurationDisplayName("Top")
        .description("The first four of your essential apps.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Bottom widget (large) — the rest

struct BlankBottomWidgetView: View {
    let entry: BlankEntry

    private var overflowApps: [LaunchableApp] {
        Array(entry.apps.dropFirst(4).prefix(8))
    }

    var body: some View {
        Group {
            if overflowApps.isEmpty {
                Text(entry.apps.isEmpty
                     ? "Open Less to\nchoose your apps"
                     : "Add more apps in Less\nto fill this widget")
                    .font(.system(size: 15))
                    .foregroundStyle(entry.secondaryColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            } else {
                // Fixed row height, top-aligned: a short list stays calm
                // instead of stretching two rows across the whole widget.
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(overflowApps) { app in
                        AppRow(app: app, color: entry.textColor)
                            .frame(height: 36)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .containerBackground(entry.backgroundColor, for: .widget)
    }
}

struct BlankBottomWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BlankBottomWidget", provider: BlankProvider()) { entry in
            BlankBottomWidgetView(entry: entry)
        }
        .configurationDisplayName("Bottom")
        .description("The rest of your essential apps.")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Bundle

@main
struct BlankWidgetsBundle: WidgetBundle {
    var body: some Widget {
        BlankTopWidget()
        BlankBottomWidget()
    }
}
