import SwiftUI

@MainActor
final class HabitStore: ObservableObject {
    @Published var habits: [Habit] = [] { didSet { save() } }
    @Published var completions: [HabitCompletion] = [] { didSet { save() } }
    private let storageKey = "WarmHabits.store.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey), let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            habits = snapshot.habits; completions = snapshot.completions
        } else {
            habits = [Habit(name: "Drink Water", icon: "💧", colorHex: "91B8C4", time: .morning), Habit(name: "Read", icon: "📚", colorHex: "F4BE65", time: .evening), Habit(name: "Run", icon: "🏃", colorHex: "A7C6A0", frequency: .specific, weekdays: [2,4,6], time: .morning), Habit(name: "Meditate", icon: "🧘", colorHex: "C7A4D6", time: .morning)]
        }
    }
    func add(_ habit: Habit) { habits.append(habit) }
    func delete(_ habit: Habit) { habits.removeAll { $0.id == habit.id }; completions.removeAll { $0.habitID == habit.id } }
    func isComplete(_ habit: Habit, on date: Date) -> Bool { completions.contains { $0.habitID == habit.id && Calendar.current.isDate($0.date, inSameDayAs: date) } }
    func toggle(_ habit: Habit, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        guard day <= Calendar.current.startOfDay(for: .now), habit.isScheduled(on: day) else { return }
        if let i = completions.firstIndex(where: { $0.habitID == habit.id && Calendar.current.isDate($0.date, inSameDayAs: day) }) { completions.remove(at: i) }
        else { completions.append(HabitCompletion(habitID: habit.id, date: day)); UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    }
    func rate(_ habit: Habit, days: Int) -> Int {
        let cal = Calendar.current; var scheduled = 0, done = 0
        for offset in 0..<days { guard let date = cal.date(byAdding: .day, value: -offset, to: .now), habit.isScheduled(on: date) else { continue }; scheduled += 1; if isComplete(habit, on: date) { done += 1 } }
        return scheduled == 0 ? 0 : Int((Double(done) / Double(scheduled) * 100).rounded())
    }
    func streak(_ habit: Habit) -> Int {
        let cal = Calendar.current; var result = 0
        for offset in 0..<366 { guard let date = cal.date(byAdding: .day, value: -offset, to: .now), habit.isScheduled(on: date) else { continue }; if isComplete(habit, on: date) { result += 1 } else if offset > 0 { break } }
        return result
    }
    private func save() { if let data = try? JSONEncoder().encode(Snapshot(habits: habits, completions: completions)) { UserDefaults.standard.set(data, forKey: storageKey) } }
    private struct Snapshot: Codable { let habits: [Habit]; let completions: [HabitCompletion] }
}
