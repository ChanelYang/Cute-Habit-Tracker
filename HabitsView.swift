import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var store: HabitStore
    @Binding var showingCreate: Bool; @Binding var selectedHabit: Habit?
    var body: some View {
        NavigationStack {
            ScrollView { VStack(spacing: 14) {
                HStack { DoodleHeader(title: "Habits", subtitle: "Your little garden"); Button { showingCreate = true } label: { Label("Add", systemImage: "plus").font(.subheadline.bold()).padding(.horizontal, 14).padding(.vertical, 9).foregroundStyle(.white).background(WarmPalette.peach, in: Capsule()) } }
                if store.habits.isEmpty { ContentUnavailableView("Nothing planted yet", systemImage: "leaf.fill", description: Text("Add one small habit to begin." )).warmCard() }
                ForEach(store.habits) { habit in
                    HStack(spacing: 14) {
                        Text(habit.icon).font(.title).frame(width: 52, height: 52).background(habit.color.opacity(0.16), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) { Text(habit.name).font(.headline).foregroundStyle(WarmPalette.ink); Text(habit.frequency.title).font(.caption).foregroundStyle(WarmPalette.muted); ProgressView(value: Double(store.rate(habit, days: 30)), total: 100).tint(habit.color) }
                        Spacer(); VStack { Text("\(store.streak(habit))").font(.title2.bold()).foregroundStyle(habit.color); Text("streak").font(.caption2).foregroundStyle(WarmPalette.muted) }
                    }.warmCard().contentShape(Rectangle()).onTapGesture { selectedHabit = habit }
                }
            }.padding(18) }.background(WarmPalette.background.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        }
    }
}
