import SwiftUI

struct RootView: View {
    @StateObject private var store = HabitStore()
    @State private var showingCreate = false
    @State private var selectedHabit: Habit?

    var body: some View {
        TabView {
            TodayView(showingCreate: $showingCreate, selectedHabit: $selectedHabit)
                .tabItem { Label("Today", systemImage: "calendar") }
            ProgressViewScreen()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
            HabitsView(showingCreate: $showingCreate, selectedHabit: $selectedHabit)
                .tabItem { Label("Habits", systemImage: "checkmark.circle") }
        }
        .tint(WarmPalette.peach).environment(\.colorScheme, .light).environmentObject(store)
        .sheet(isPresented: $showingCreate) { CreateHabitView().environmentObject(store) }
        .sheet(item: $selectedHabit) { HabitDetailView(habit: $0).environmentObject(store) }
    }
}
