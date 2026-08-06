import SwiftUI

/// Recreates the blankspaces.app/widgets-tutorial walkthrough.
struct WidgetTutorialView: View {
    @EnvironmentObject private var store: AppStore
    private var pal: Palette { store.palette }

    private struct Step: Identifiable {
        let id: Int
        let symbol: String
        let title: String
        let body: String
    }

    private let steps: [Step] = [
        .init(id: 1, symbol: "hand.tap",
              title: "Long press",
              body: "Long-press on an empty area of your Home Screen until all the apps start wiggling. Tap the plus icon at the top left to open the widget menu."),
        .init(id: 2, symbol: "chevron.left.square",
              title: "Find the Less icon",
              body: "You can identify Less by its < logo. Search \"Less\" and tap the icon."),
        .init(id: 3, symbol: "plus.square.on.square",
              title: "Add a widget",
              body: "Add the large List widget for all your apps, or the medium Top widget if you only need your first four. Tap the add button at the bottom."),
        .init(id: 4, symbol: "square.stack",
              title: "Hide extra pages",
              body: "Long-press on an empty area of your Home Screen. Tap the dots at the bottom to bring up the edit-pages screen. Uncheck the pages you want to hide."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Add the widgets")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(pal.textPrimary)
                    .padding(.top, 16)

                ForEach(steps) { step in
                    HStack(alignment: .top, spacing: 18) {
                        ZStack {
                            Circle()
                                .stroke(pal.hairline, lineWidth: 1)
                                .frame(width: 40, height: 40)
                            Text("\(step.id)")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(pal.textPrimary)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: step.symbol)
                                    .font(.system(size: 15))
                                    .foregroundStyle(pal.mist)
                                Text(step.title)
                                    .font(.system(size: 19, weight: .medium))
                                    .foregroundStyle(pal.textPrimary)
                            }
                            Text(step.body)
                                .font(.system(size: 15))
                                .foregroundStyle(pal.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                }

                widgetPreview
            }
            .padding(28)
        }
        .background(pal.background)
        .navigationTitle("Widget tutorial")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// A mock of what the finished home screen looks like.
    private var widgetPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WHAT IT'LL LOOK LIKE")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(pal.textTertiary)
                .kerning(1.2)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(["Phone", "Messages", "Camera", "Maps", "Notes", "Music"], id: \.self) { name in
                    Text(name)
                        .font(.system(size: 20))
                        .foregroundStyle(store.theme == .black ? .white : Color(red: 0.07, green: 0.07, blue: 0.08))
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(store.theme == .black ? Color.black : Color(red: 0.97, green: 0.96, blue: 0.94), in: RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(pal.hairline, lineWidth: 1)
            )
        }
        .padding(.top, 12)
    }
}
