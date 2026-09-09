import SwiftUI

struct HabitDot: View {
    let habit: Habit
    let date: Date
    let complete: Bool
    var size: CGFloat = 34
    var celebrating = false

    var body: some View {
        ZStack {
            Circle().fill(complete ? habit.color : .clear)
            if !complete { Circle().stroke(habit.color.opacity(date > .now ? 0.25 : 0.75), style: StrokeStyle(lineWidth: 2, dash: [3, 3])) }
            Text(habit.icon).font(.system(size: size * 0.45))
            if complete {
                Image(systemName: "checkmark").font(.system(size: 8, weight: .bold)).foregroundStyle(habit.color)
                    .frame(width: 15, height: 15).background(.white, in: Circle()).offset(x: size * 0.37, y: size * 0.37)
            }
            if celebrating { CelebrationView(color: habit.color).allowsHitTesting(false) }
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .accessibilityLabel("\(habit.name), \(complete ? "completed" : "not completed")")
    }
}

struct CelebrationView: View {
    let color: Color
    @State private var burst = false
    private let symbols = ["sparkle", "star.fill", "heart.fill", "leaf.fill", "sparkles"]
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { i in
                Image(systemName: symbols[i % symbols.count]).font(.system(size: CGFloat(7 + i % 3 * 2), weight: .bold)).foregroundStyle(i.isMultiple(of: 2) ? color : WarmPalette.peach)
                    .offset(x: burst ? cos(Double(i) * .pi / 5) * 48 : 0, y: burst ? sin(Double(i) * .pi / 5) * 48 : 0)
                    .scaleEffect(burst ? 0.15 : 1).opacity(burst ? 0 : 1)
            }
        }.onAppear { withAnimation(.easeOut(duration: 0.75)) { burst = true } }
    }
}

struct DoodleHeader: View {
    let title: String
    let subtitle: String?
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                if let subtitle { Text(subtitle).font(.subheadline.weight(.medium)).foregroundStyle(WarmPalette.muted) }
                Text(title).font(.largeTitle.bold()).foregroundStyle(WarmPalette.ink)
            }
            Spacer()
            ZStack {
                Image(systemName: "sun.max.fill").font(.title).foregroundStyle(Color(hex: "F4BE65"))
                Text("⌣").font(.caption.bold()).foregroundStyle(WarmPalette.ink).offset(y: 2)
            }.rotationEffect(.degrees(7))
        }
    }
}

extension View {
    func warmCard() -> some View { self.padding(16).background(WarmPalette.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous)).shadow(color: WarmPalette.ink.opacity(0.06), radius: 10, y: 4) }
}
