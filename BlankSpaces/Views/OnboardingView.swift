import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $page) {
                slide(
                    headline: "Our screens steal 7+ hours from us each day.",
                    sub: "That's half your waking life spent looking down.",
                    tag: 0
                )
                slide(
                    headline: "Turn your phone into a minimal dumbphone.",
                    sub: "Only the apps you need, nothing else. A serene, clutter-free zone.",
                    tag: 1
                )
                slide(
                    headline: "Block addicting apps.",
                    sub: "A breathing exercise creates just enough friction to ask: do I actually need to open this?",
                    tag: 2
                )
                finalSlide.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
    }

    private func slide(headline: String, sub: String, tag: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("<")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(.white)
            Text(headline)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .lineSpacing(2)
            Text(sub)
                .font(.system(size: 17))
                .foregroundStyle(.gray)
                .lineSpacing(3)
            Spacer()
            Spacer()
        }
        .padding(36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tag(tag)
    }

    private var finalSlide: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("Start your digital detox.")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
            Text("Scroll less. Live more. It starts with one tap.")
                .font(.system(size: 17))
                .foregroundStyle(.gray)
            Spacer()

            Button(action: onFinish) {
                Text("Get started")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white, in: Capsule())
            }
            .padding(.bottom, 60)
        }
        .padding(36)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
