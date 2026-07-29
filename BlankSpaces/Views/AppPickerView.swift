import SwiftUI

struct AppPickerView: View {
    @EnvironmentObject private var store: AppStore
    @State private var customName = ""
    @State private var customScheme = ""

    private var pal: Palette { store.palette }

    var body: some View {
        List {
            Section {
                Text("Pick the handful of apps you actually need. Everything else stays out of sight. Apps marked with a breath icon open only after a breathing exercise.")
                    .font(.system(size: 14))
                    .foregroundStyle(pal.textSecondary)
                    .listRowBackground(Color.clear)
            }

            selectedSection
            catalogSection(title: "ESSENTIALS", apps: AppCatalog.essentials)
            catalogSection(title: "EVERYDAY APPS", apps: AppCatalog.thirdParty)
            catalogSection(title: "DISTRACTIONS · GATED BY DEFAULT", apps: AppCatalog.distractions)
            customSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(pal.background)
        .navigationTitle("Choose your apps")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectedSection: some View {
        Section {
            if store.apps.isEmpty {
                Text("Nothing selected yet.")
                    .foregroundStyle(pal.textTertiary)
                    .listRowBackground(pal.surface)
            }
            ForEach(store.apps) { app in
                HStack {
                    Text(app.name)
                        .foregroundStyle(pal.textPrimary)
                    Spacer()
                    Button {
                        store.setBlocked(!app.isBlocked, for: app)
                    } label: {
                        Image(systemName: app.isBlocked ? "wind" : "wind.circle")
                            .foregroundStyle(app.isBlocked ? pal.amber : pal.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(pal.surface)
            }
            .onDelete { store.apps.remove(atOffsets: $0) }
            .onMove { store.apps.move(fromOffsets: $0, toOffset: $1) }
        } header: {
            Text("ON YOUR WIDGET · DRAG TO REORDER")
                .foregroundStyle(pal.textTertiary)
        }
    }

    private func catalogSection(title: String, apps: [LaunchableApp]) -> some View {
        Section {
            ForEach(apps) { app in
                Button {
                    store.toggle(app)
                } label: {
                    HStack {
                        Text(app.name)
                            .foregroundStyle(pal.textPrimary)
                        if app.isBlocked {
                            Image(systemName: "wind")
                                .font(.system(size: 12))
                                .foregroundStyle(pal.amber)
                        }
                        Spacer()
                        Image(systemName: store.isSelected(app) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(store.isSelected(app) ? pal.sage : pal.textTertiary)
                    }
                }
                .listRowBackground(pal.surface)
            }
        } header: {
            Text(title)
                .foregroundStyle(pal.textTertiary)
        }
    }

    private var customSection: some View {
        Section {
            TextField("Name (e.g. Strava)", text: $customName)
                .listRowBackground(pal.surface)
            TextField("URL scheme (e.g. strava://)", text: $customScheme)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .listRowBackground(pal.surface)
            Button("Add custom app") {
                let name = customName.trimmingCharacters(in: .whitespaces)
                let scheme = customScheme.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty, !scheme.isEmpty else { return }
                store.apps.append(LaunchableApp(name: name, scheme: scheme))
                customName = ""
                customScheme = ""
            }
            .foregroundStyle(pal.mist)
            .listRowBackground(pal.surface)
        } header: {
            Text("CUSTOM")
                .foregroundStyle(pal.textTertiary)
        } footer: {
            Text("Any app that registers a URL scheme can be added. Search \"<app name> URL scheme\" to find one.")
                .foregroundStyle(pal.textTertiary)
        }
    }
}
