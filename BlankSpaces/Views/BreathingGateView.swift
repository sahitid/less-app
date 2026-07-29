import SwiftUI

/// Full-screen friction gate: a guided breathing exercise that must finish
/// before a blocked app opens. Shown when a gated app is tapped on the widget.
struct BreathingGateView: View {
    let app: LaunchableApp

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    private enum Phase { case inhale, exhale, done }

    @State private var phase: Phase = .inhale
    @State private var breathsRemaining = SharedStore.breathCount
    @State private var scale: CGFloat = 0.45

    private let breathDuration: Double = 4

    private var pal: Palette { store.palette }

    var body: some View {
        ZStack {
            pal.background.ignoresSafeArea()

            VStack(spacing: 48) {
                Spacer()

                Text(label)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(pal.textPrimary)
                    .animation(.none, value: phase)

                Circle()
                    .stroke(pal.sage.opacity(0.9), lineWidth: 1.5)
                    .background(Circle().fill(pal.sage.opacity(0.08)))
                    .frame(width: 220, height: 220)
                    .scaleEffect(scale)

                Spacer()

                if phase == .done {
                    VStack(spacing: 18) {
                        Button {
                            store.stats.pausesCompleted += 1
                            store.open(app)
                            dismiss()
                        } label: {
                            Text("Open \(app.name)")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(pal.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(pal.textPrimary, in: Capsule())
                        }

                        Button {
                            store.stats.pausesCompleted += 1
                            store.stats.opensAvoided += 1
                            dismiss()
                        } label: {
                            Text("Never mind, reclaim my time")
                                .font(.system(size: 15))
                                .foregroundStyle(pal.sage)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                } else {
                    VStack(spacing: 12) {
                        Text("\(breathsRemaining) breath\(breathsRemaining == 1 ? "" : "s") to go")
                            .font(.system(size: 14))
                            .foregroundStyle(pal.textSecondary)
                        Button("Give up") {
                            store.stats.opensAvoided += 1
                            dismiss()
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(pal.textTertiary)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear(perform: runBreath)
    }

    private var label: String {
        switch phase {
        case .inhale: "Breathe in"
        case .exhale: "Breathe out"
        case .done: "Do you still want \(app.name)?"
        }
    }

    private func runBreath() {
        guard breathsRemaining > 0 else {
            withAnimation(.easeOut(duration: 0.5)) { phase = .done }
            return
        }

        phase = .inhale
        withAnimation(.easeInOut(duration: breathDuration)) { scale = 1.0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
            phase = .exhale
            withAnimation(.easeInOut(duration: breathDuration)) { scale = 0.45 }

            DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
                breathsRemaining -= 1
                runBreath()
            }
        }
    }
}
