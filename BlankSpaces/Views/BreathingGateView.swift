import SwiftUI

/// Full-screen friction gate: a guided breathing exercise that must finish
/// before a blocked app opens. Shown when a gated app is tapped on the widget.
struct BreathingGateView: View {
    let app: LaunchableApp

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    private enum Phase { case inhale, exhale, done }

    private static let intentOptions = ["Reply to someone", "Look something up", "Post something", "Just bored"]

    @State private var phase: Phase = .inhale
    @State private var breathsRemaining: Int
    @State private var scale: CGFloat = 0.45
    @State private var intent: String?
    @State private var sessionMinutes = SharedStore.sessionMinutes

    /// True when reopening within the window bumped the breath count.
    private let escalated: Bool

    private let breathDuration: Double = 4

    private var pal: Palette { store.palette }

    init(app: LaunchableApp) {
        self.app = app
        let extra = SharedStore.escalationBreaths(for: app.scheme)
        let breaths = min(SharedStore.breathCount + extra, BlankSpacesConfig.maxBreaths)
        _breathsRemaining = State(initialValue: breaths)
        escalated = extra > 0
    }

    /// "Just bored" flips the emphasis: closing becomes the primary action.
    private var bored: Bool { intent == "Just bored" }

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
                    doneControls
                        .transition(.opacity)
                } else {
                    VStack(spacing: 12) {
                        Text("\(breathsRemaining) breath\(breathsRemaining == 1 ? "" : "s") to go")
                            .font(.system(size: 14))
                            .foregroundStyle(pal.textSecondary)
                        if escalated {
                            Text("Back again so soon? A few extra breaths this time.")
                                .font(.system(size: 12))
                                .foregroundStyle(pal.amber.opacity(0.8))
                        }
                        Button("Give up") {
                            store.stats.recordOpenAvoided()
                            dismiss()
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(pal.textTertiary)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            SharedStore.noteGateShown(for: app.scheme)
            runBreath()
        }
    }

    private var doneControls: some View {
        VStack(spacing: 24) {
            // Intention prompt
            VStack(spacing: 10) {
                Text("What for?")
                    .font(.system(size: 13))
                    .foregroundStyle(pal.textSecondary)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Self.intentOptions, id: \.self) { option in
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) { intent = option }
                        } label: {
                            Text(option)
                                .font(.system(size: 13))
                                .foregroundStyle(intent == option ? pal.background : pal.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    intent == option ? pal.textPrimary : pal.surface,
                                    in: Capsule()
                                )
                        }
                    }
                }
            }

            // Session timebox
            VStack(spacing: 10) {
                Text("For how long?")
                    .font(.system(size: 13))
                    .foregroundStyle(pal.textSecondary)
                HStack(spacing: 8) {
                    ForEach([5, 10, 15], id: \.self) { minutes in
                        Button {
                            sessionMinutes = minutes
                        } label: {
                            Text("\(minutes) min")
                                .font(.system(size: 13))
                                .foregroundStyle(sessionMinutes == minutes ? pal.background : pal.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    sessionMinutes == minutes ? pal.textPrimary : pal.surface,
                                    in: Capsule()
                                )
                        }
                    }
                }
            }

            VStack(spacing: 14) {
                if bored {
                    reclaimButton(primary: true)
                    openButton(primary: false)
                } else {
                    openButton(primary: true)
                    reclaimButton(primary: false)
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 32)
    }

    private func openButton(primary: Bool) -> some View {
        Button {
            store.stats.recordPauseCompleted()
            if let intent { store.stats.recordIntent(intent) }
            SharedStore.sessionMinutes = sessionMinutes
            SessionNudge.schedule(minutes: sessionMinutes, appName: app.name)
            store.open(app)
            dismiss()
        } label: {
            if primary {
                Text("Open \(app.name) for \(sessionMinutes) min")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(pal.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(pal.textPrimary, in: Capsule())
            } else {
                Text("Open \(app.name) anyway")
                    .font(.system(size: 15))
                    .foregroundStyle(pal.textTertiary)
            }
        }
    }

    private func reclaimButton(primary: Bool) -> some View {
        Button {
            store.stats.recordPauseCompleted()
            store.stats.recordOpenAvoided()
            if let intent { store.stats.recordIntent(intent) }
            dismiss()
        } label: {
            if primary {
                Text("Never mind, reclaim my time")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(pal.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(pal.sage, in: Capsule())
            } else {
                Text("Never mind, reclaim my time")
                    .font(.system(size: 15))
                    .foregroundStyle(pal.sage)
            }
        }
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
