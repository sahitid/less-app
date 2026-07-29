import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var breathCount = SharedStore.breathCount

    private var pal: Palette { store.palette }

    var body: some View {
        List {
            Section {
                Picker("Theme", selection: $store.theme) {
                    ForEach(BlankTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(pal.surface)
            } header: {
                Text("APPEARANCE")
                    .foregroundStyle(pal.textTertiary)
            } footer: {
                Text("Ink is white-on-black; Paper is black-on-white. The widgets follow along, so pair it with a matching wallpaper for a seamless home screen.")
                    .foregroundStyle(pal.textTertiary)
            }

            Section {
                NavigationLink {
                    WallpaperView()
                } label: {
                    Label {
                        Text("Match your wallpaper")
                            .foregroundStyle(pal.textPrimary)
                    } icon: {
                        Image(systemName: "paintpalette")
                            .foregroundStyle(pal.sage)
                    }
                }
                .listRowBackground(pal.surface)
            }

            Section {
                Stepper(value: $breathCount, in: 1...10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Breaths to unlock")
                            .foregroundStyle(pal.textPrimary)
                        Text("\(breathCount) breath\(breathCount == 1 ? "" : "s") ≈ \(breathCount * 8) seconds")
                            .font(.system(size: 13))
                            .foregroundStyle(pal.textTertiary)
                    }
                }
                .onChange(of: breathCount) { _, newValue in
                    SharedStore.breathCount = newValue
                }
                .listRowBackground(pal.surface)
            } header: {
                Text("FRICTION")
                    .foregroundStyle(pal.textTertiary)
            } footer: {
                Text("How many guided breaths before a gated app opens.")
                    .foregroundStyle(pal.textTertiary)
            }

            Section {
                Button("Reset statistics") {
                    store.stats = UsageStats()
                }
                .foregroundStyle(.red)
                .listRowBackground(pal.surface)
            } header: {
                Text("DATA")
                    .foregroundStyle(pal.textTertiary)
            }

            Section {
                Text("Less is a personal recreation of blankspaces.app, built for personal use. Not affiliated with Ecstasis LLC.")
                    .font(.system(size: 13))
                    .foregroundStyle(pal.textTertiary)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(pal.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
