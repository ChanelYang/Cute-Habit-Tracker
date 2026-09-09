import SwiftUI

struct ProgressViewScreen: View {
    @EnvironmentObject private var store: HabitStore
    private var todayHabits: [Habit] { store.habits.filter { $0.isScheduled(on: .now) } }
    private var done: Int { todayHabits.filter { store.isComplete($0, on: .now) }.count }
    var body: some View {
        NavigationStack {
            ScrollView { VStack(spacing: 16) {
                DoodleHeader(title: "Progress", subtitle: "Look how you’re growing")
                HStack(spacing: 12) { stat("Today", "\(done)/\(todayHabits.count)", "habits done", WarmPalette.peach); stat("This month", "\(average)%", "completion", Color(hex: "A7C6A0")) }
                VStack(alignment: .leading, spacing: 16) {
                    Label("Current Streaks", systemImage: "flame.fill").font(.headline).foregroundStyle(WarmPalette.ink)
                    ForEach(store.habits.sorted { store.streak($0) > store.streak($1) }) { habit in
                        HStack { Text(habit.icon).font(.title2).frame(width: 42, height: 42).background(habit.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 14)); VStack(alignment: .leading) { Text(habit.name).bold(); ProgressView(value: Double(store.rate(habit, days: 30)), total: 100).tint(habit.color) }; Spacer(); Text("\(store.streak(habit)) days").font(.subheadline.bold()).foregroundStyle(habit.color) }
                    }
                }.foregroundStyle(WarmPalette.ink).warmCard()
                VStack(alignment: .leading, spacing: 12) { Text("30-Day Completion").font(.headline); ForEach(store.habits) { habit in HStack { Text(habit.icon); Text(habit.name); Spacer(); Text("\(store.rate(habit, days: 30))%").bold().foregroundStyle(habit.color) } } }.foregroundStyle(WarmPalette.ink).warmCard()
            }.padding(18) }.background(WarmPalette.background.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        }
    }
    private var average: Int { store.habits.isEmpty ? 0 : store.habits.map { store.rate($0, days: 30) }.reduce(0,+) / store.habits.count }
    private func stat(_ title: String, _ value: String, _ subtitle: String, _ color: Color) -> some View { VStack(alignment: .leading, spacing: 5) { Text(title.uppercased()).font(.caption2.bold()).foregroundStyle(WarmPalette.muted); Text(value).font(.largeTitle.bold()).foregroundStyle(color); Text(subtitle).font(.caption).foregroundStyle(WarmPalette.muted) }.frame(maxWidth: .infinity, alignment: .leading).warmCard() }
}
