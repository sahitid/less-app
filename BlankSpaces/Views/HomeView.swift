import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore

    private var pal: Palette { store.palette }

    var body: some View {
        NavigationStack {
            ZStack {
                pal.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Space.xl) {
                        header
                        reclaimedCard
                        if !store.wallpaperDone {
                            wallpaperNudge
                        }
                        appListPreview
                        actions
                    }
                    .padding(Space.lg)
                }
            }
            .toolbarColorScheme(store.theme == .black ? .dark : .light, for: .navigationBar)
        }
        .tint(pal.textPrimary)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text("<")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(pal.textPrimary)
            Text("Less")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(pal.textPrimary)
            Text("Scroll less. Live more.")
                .font(.system(size: 17))
                .foregroundStyle(pal.textSecondary)
        }
        .padding(.top, Space.lg)
    }

    private var reclaimedCard: some View {
        VStack(alignment: .leading, spacing: Space.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: Space.xs) {
                Text("\(store.stats.minutesReclaimed / 60)h \(store.stats.minutesReclaimed % 60)m")
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(pal.sage)
                    .contentTransition(.numericText())
                Image(systemName: "leaf")
                    .font(.system(size: 18))
                    .foregroundStyle(pal.sage.opacity(0.7))
            }
            Text("reclaimed so far")
                .font(.system(size: 15))
                .foregroundStyle(pal.textSecondary)

            Rectangle()
                .fill(pal.hairline)
                .frame(height: 1)
                .padding(.vertical, Space.md)

            HStack(spacing: Space.xl) {
                stat(value: store.stats.pausesCompleted, label: "pauses taken", color: pal.mist)
                stat(value: store.stats.opensAvoided, label: "opens avoided", color: pal.amber)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Space.lg)
        .background(pal.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private func stat(value: Int, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Space.xxs) {
            Text("\(value)")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(pal.textTertiary)
        }
    }

    private var wallpaperNudge: some View {
        NavigationLink {
            WallpaperView()
        } label: {
            HStack(spacing: Space.md) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 18))
                    .foregroundStyle(pal.sage)
                    .frame(width: 40, height: 40)
                    .background(pal.sage.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Make it seamless")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(pal.textPrimary)
                    Text("Match your wallpaper to \(store.theme == .black ? "black" : "white") so the widgets disappear into it.")
                        .font(.system(size: 13))
                        .foregroundStyle(pal.textSecondary)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(pal.textTertiary)
            }
            .padding(Space.md)
            .background(pal.sage.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(pal.sage.opacity(0.25), lineWidth: 1)
            )
        }
    }

    private var appListPreview: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Text("YOUR HOME SCREEN")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(pal.textTertiary)
                .kerning(1.2)

            VStack(alignment: .leading, spacing: Space.md) {
                ForEach(store.apps) { app in
                    HStack(spacing: Space.xs) {
                        Text(app.name)
                            .font(.system(size: 19))
                            .foregroundStyle(pal.textPrimary)
                        if app.isBlocked {
                            Image(systemName: "wind")
                                .font(.system(size: 13))
                                .foregroundStyle(pal.amber)
                        }
                        Spacer()
                    }
                }
                if store.apps.isEmpty {
                    Text("No apps yet. Add a few below.")
                        .font(.system(size: 15))
                        .foregroundStyle(pal.textSecondary)
                }
            }
            .padding(Space.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(pal.surface, in: RoundedRectangle(cornerRadius: 20))
        }
    }

    private var actions: some View {
        VStack(spacing: Space.sm) {
            NavigationLink {
                AppPickerView()
            } label: {
                actionRow(icon: "square.grid.2x2", tint: pal.mist, title: "Choose your apps")
            }
            NavigationLink {
                WallpaperView()
            } label: {
                actionRow(icon: "paintpalette", tint: pal.sage, title: "Match your wallpaper")
            }
            NavigationLink {
                WidgetTutorialView()
            } label: {
                actionRow(icon: "plus.square.on.square", tint: pal.amber, title: "Add the widgets")
            }
            NavigationLink {
                SettingsView()
            } label: {
                actionRow(icon: "gearshape", tint: pal.textSecondary, title: "Settings")
            }
        }
    }

    private func actionRow(icon: String, tint: Color, title: String) -> some View {
        HStack(spacing: Space.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(pal.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(pal.textTertiary)
        }
        .padding(Space.md)
        .background(pal.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}
