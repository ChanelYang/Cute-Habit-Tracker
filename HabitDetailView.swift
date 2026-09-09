import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: HabitStore
    @State private var confirmDelete = false
    var body: some View {
        NavigationStack {
            ScrollView { VStack(spacing: 16) {
                VStack(spacing: 8) { Text(habit.icon).font(.system(size: 48)).frame(width: 82, height: 82).background(habit.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 28)); Text(habit.name).font(.title2.bold()); Text("Keep going—you’re doing lovely ✦").font(.caption).foregroundStyle(WarmPalette.muted) }.foregroundStyle(WarmPalette.ink)
                HStack(spacing: 10) { tile("🔥", "\(store.streak(habit))", "current"); tile("🏆", "\(store.streak(habit))", "best"); tile("📈", "\(store.rate(habit, days: 30))%", "30 days") }
                VStack(alignment: .leading, spacing: 13) { Text("Schedule").font(.headline); row("Frequency", habit.frequency.title); row("Time", habit.time.title); row("Reminder", habit.reminder ? "On" : "Off"); row("Started", habit.startDate.formatted(date: .abbreviated, time: .omitted)) }.foregroundStyle(WarmPalette.ink).warmCard()
                Button { store.toggle(habit, on: .now) } label: { Label(store.isComplete(habit, on: .now) ? "Completed Today — Tap to Undo" : "Mark Complete Today", systemImage: "checkmark.circle.fill").frame(maxWidth: .infinity).padding() }.buttonStyle(.plain).foregroundStyle(.white).background(habit.color, in: RoundedRectangle(cornerRadius: 20))
                Button("Delete Habit", role: .destructive) { confirmDelete = true }
            }.padding(18) }.background(WarmPalette.background.ignoresSafeArea()).navigationTitle("Habit Details").navigationBarTitleDisplayMode(.inline).toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }.alert("Delete \(habit.name)?", isPresented: $confirmDelete) { Button("Delete", role: .destructive) { store.delete(habit); dismiss() }; Button("Cancel", role: .cancel) {} } message: { Text("Its completion history will also be removed.") }
        }.tint(WarmPalette.peach)
    }
    private func tile(_ icon: String, _ value: String, _ label: String) -> some View { VStack(spacing: 3) { Text(icon); Text(value).font(.title2.bold()).foregroundStyle(habit.color); Text(label).font(.caption2).foregroundStyle(WarmPalette.muted) }.frame(maxWidth: .infinity).warmCard() }
    private func row(_ label: String, _ value: String) -> some View { HStack { Text(label).foregroundStyle(WarmPalette.muted); Spacer(); Text(value).bold() } }
}
