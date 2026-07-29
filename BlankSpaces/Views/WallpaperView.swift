import SwiftUI
import Photos

/// Recommends a wallpaper that matches the widget background so the whole
/// home screen reads as one blank surface. iOS offers no API to set the
/// wallpaper, so this view does the two legitimate things an app can do:
/// walk the user through iOS's native solid-color flow, and save a
/// pixel-matched solid image to Photos as an alternative.
struct WallpaperView: View {
    @EnvironmentObject private var store: AppStore
    @State private var saveState: SaveState = .idle

    private enum SaveState: Equatable {
        case idle, saving, saved, denied
    }

    private var pal: Palette { store.palette }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                header
                phonePreview
                stepsCard
                saveCard
                doneToggle
            }
            .padding(Space.lg)
        }
        .background(pal.background)
        .navigationTitle("Match your wallpaper")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text("Disappear the seams.")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(pal.textPrimary)
            Text("Widgets sit on top of your wallpaper. Set it to the same \(store.theme == .black ? "black" : "white") as Less and the edges vanish. Your home screen becomes a single, calm surface.")
                .font(.system(size: 15))
                .foregroundStyle(pal.textSecondary)
                .lineSpacing(3)
        }
        .padding(.top, Space.md)
    }

    /// Before/after: widget on a photo wallpaper vs. on a matched solid.
    private var phonePreview: some View {
        HStack(spacing: Space.md) {
            miniPhone(matched: false, label: "Mismatched")
            miniPhone(matched: true, label: "Matched")
        }
        .frame(maxWidth: .infinity)
    }

    private func miniPhone(matched: Bool, label: String) -> some View {
        VStack(spacing: Space.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        matched
                        ? AnyShapeStyle(store.theme == .black ? Color.black : Color(red: 0.97, green: 0.96, blue: 0.94))
                        : AnyShapeStyle(LinearGradient(
                            colors: [pal.mist.opacity(0.55), pal.amber.opacity(0.45)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .frame(width: 120, height: 240)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(pal.hairline, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: Space.xs) {
                    ForEach(["Phone", "Messages", "Notes"], id: \.self) { name in
                        Text(name)
                            .font(.system(size: 11))
                            .foregroundStyle(store.theme == .black ? .white : Color(red: 0.07, green: 0.07, blue: 0.08))
                            .padding(.horizontal, Space.xs)
                            .padding(.vertical, 3)
                            .background(
                                matched
                                ? Color.clear
                                : (store.theme == .black ? Color.black : Color(red: 0.97, green: 0.96, blue: 0.94)),
                                in: RoundedRectangle(cornerRadius: 5)
                            )
                    }
                }
                .frame(width: 96, alignment: .leading)
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(matched ? pal.sage : pal.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Label("Recommended · takes 30 seconds", systemImage: "paintpalette")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(pal.sage)
                .kerning(0.5)
                .textCase(.uppercase)

            step(1, "Open **Settings → Wallpaper**, tap **Add New Wallpaper**.")
            step(2, "Choose **Color** at the top.")
            step(3, "Pick \(store.theme == .black ? "black" : "white"), then swipe to the **Solid** style.")
            step(4, "Tap **Add → Set as Wallpaper Pair**.")
        }
        .padding(Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(pal.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: Space.sm) {
            Text("\(number)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(pal.background)
                .frame(width: 22, height: 22)
                .background(pal.textPrimary, in: Circle())
            Text(.init(text))
                .font(.system(size: 15))
                .foregroundStyle(pal.textPrimary)
                .lineSpacing(2)
        }
    }

    private var saveCard: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            Label("Or save an exact-match image", systemImage: "photo")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(pal.mist)
                .kerning(0.5)
                .textCase(.uppercase)

            Text("Less saves a solid \(store.theme == .black ? "black" : "white") image sized for your screen. Then in Photos: Share → Use as Wallpaper.")
                .font(.system(size: 14))
                .foregroundStyle(pal.textSecondary)
                .lineSpacing(2)

            Button(action: saveWallpaper) {
                HStack(spacing: Space.xs) {
                    switch saveState {
                    case .idle:
                        Image(systemName: "square.and.arrow.down")
                        Text("Save to Photos")
                    case .saving:
                        ProgressView().tint(pal.background)
                        Text("Saving…")
                    case .saved:
                        Image(systemName: "checkmark")
                        Text("Saved to Photos")
                    case .denied:
                        Image(systemName: "exclamationmark.triangle")
                        Text("Allow Photos access in Settings")
                    }
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(saveState == .denied ? pal.textPrimary : pal.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    saveState == .denied ? pal.surfaceRaised : (saveState == .saved ? pal.sage : pal.textPrimary),
                    in: Capsule()
                )
            }
            .disabled(saveState == .saving)
        }
        .padding(Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(pal.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private var doneToggle: some View {
        Toggle(isOn: $store.wallpaperDone) {
            VStack(alignment: .leading, spacing: 2) {
                Text("I've set my wallpaper")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(pal.textPrimary)
                Text("Hides the reminder on the home screen.")
                    .font(.system(size: 13))
                    .foregroundStyle(pal.textTertiary)
            }
        }
        .tint(pal.sage)
        .padding(Space.lg)
        .background(pal.surface, in: RoundedRectangle(cornerRadius: 20))
    }

    private func saveWallpaper() {
        saveState = .saving
        let color: UIColor = store.theme == .black ? .black : UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1)
        let bounds = UIScreen.main.bounds
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let image = UIGraphicsImageRenderer(size: bounds.size, format: format).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: bounds.size))
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { saveState = .denied }
                return
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    saveState = success ? .saved : .denied
                    if success { store.wallpaperDone = true }
                }
            }
        }
    }
}
