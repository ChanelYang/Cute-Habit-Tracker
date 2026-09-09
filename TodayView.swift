import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: HabitStore
    @Binding var showingCreate: Bool; @Binding var selectedHabit: Habit?
    @State private var mode = 0
    @State private var referenceDate = Date.now
    @State private var celebratingKey: String?

    private var habits: [Habit] { store.habits }
    private var completions: [HabitCompletion] { store.completions }
    private var todayHabits: [Habit] { habits.filter { $0.isScheduled(on: .now) } }
    private var completedCount: Int { todayHabits.filter { store.isComplete($0, on: .now) }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        DoodleHeader(title: "Today", subtitle: Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                        Button { showingCreate = true } label: { Image(systemName: "plus").font(.title3.bold()).foregroundStyle(.white).frame(width: 42, height: 42).background(WarmPalette.peach, in: Circle()) }
                    }
                    progressHeader
                    calendarCard
                    habitList
                }.padding(18)
            }.background(WarmPalette.background.ignoresSafeArea()).toolbar(.hidden, for: .navigationBar)
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 7) {
            HStack { Text("\(completedCount) of \(todayHabits.count) completed"); Spacer(); Text("\(todayHabits.isEmpty ? 0 : completedCount * 100 / todayHabits.count)%").foregroundStyle(WarmPalette.peach).bold() }.font(.caption)
            GeometryReader { geo in ZStack(alignment: .leading) { Capsule().fill(WarmPalette.peach.opacity(0.15)); Capsule().fill(WarmPalette.peach).frame(width: geo.size.width * CGFloat(completedCount) / CGFloat(max(todayHabits.count, 1))) } }.frame(height: 7)
        }.foregroundStyle(WarmPalette.muted)
    }

    private var calendarCard: some View {
        VStack(spacing: 14) {
            Picker("Calendar view", selection: $mode) { Text("Week").tag(0); Text("Month").tag(1) }.pickerStyle(.segmented)
            HStack { Button { shift(-1) } label: { Image(systemName: "chevron.left") }; Spacer(); Text(referenceDate.formatted(.dateTime.month(.wide).year())).font(.subheadline.bold()).foregroundStyle(WarmPalette.ink); Spacer(); Button { shift(1) } label: { Image(systemName: "chevron.right") } }.foregroundStyle(WarmPalette.muted)
            if mode == 0 { WeekCalendarView(habits: habits, completions: completions, referenceDate: referenceDate, celebratingKey: celebratingKey, toggle: toggle) }
            else { MonthCalendarView(habits: habits, completions: completions, referenceDate: referenceDate, toggle: toggle) }
        }.warmCard()
    }

    @ViewBuilder private var habitList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today’s Habits").font(.title3.bold()).foregroundStyle(WarmPalette.ink)
            if todayHabits.isEmpty { ContentUnavailableView("A fresh little start", systemImage: "leaf.fill", description: Text("Create your first habit and grow from there.")) }
            ForEach(todayHabits) { habit in
                let done = store.isComplete(habit, on: .now)
                HStack(spacing: 13) {
                    HabitDot(habit: habit, date: .now, complete: done, celebrating: celebratingKey == HabitCompletion(habitID: habit.id, date: .now).key).onTapGesture(count: 2) { toggle(habit, .now) }
                    VStack(alignment: .leading) { Text(habit.name).font(.body.bold()).strikethrough(done).foregroundStyle(WarmPalette.ink.opacity(done ? 0.5 : 1)); Text("\(habit.time.title) · 🔥 \(store.streak(habit)) day streak").font(.caption).foregroundStyle(WarmPalette.muted) }
                    Spacer()
                    Button(done ? "Done" : "Mark") { toggle(habit, .now) }.buttonStyle(.bordered).tint(habit.color)
                }.warmCard().contentShape(Rectangle()).onTapGesture { selectedHabit = habit }
            }
        }
    }

    private func shift(_ direction: Int) { withAnimation { referenceDate = Calendar.current.date(byAdding: mode == 0 ? .weekOfYear : .month, value: direction, to: referenceDate) ?? referenceDate } }
    private func toggle(_ habit: Habit, _ date: Date) {
        let wasDone = store.isComplete(habit, on: date)
        store.toggle(habit, on: date)
        if !wasDone { celebratingKey = HabitCompletion(habitID: habit.id, date: date).key; DispatchQueue.main.asyncAfter(deadline: .now() + 1) { celebratingKey = nil } }
    }
}

struct WeekCalendarView: View {
    let habits: [Habit]; let completions: [HabitCompletion]; let referenceDate: Date; let celebratingKey: String?; let toggle: (Habit, Date) -> Void
    var days: [Date] { let cal = Calendar.current; let interval = cal.dateInterval(of: .weekOfYear, for: referenceDate)!; return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: interval.start) } }
    var body: some View {
        HStack(alignment: .top, spacing: 4) { ForEach(days, id: \.self) { day in VStack(spacing: 7) { Text(day.formatted(.dateTime.weekday(.narrow))).font(.caption2.bold()).foregroundStyle(WarmPalette.muted); Text(day.formatted(.dateTime.day())).font(.subheadline.bold()).frame(width: 28, height: 28).background(Calendar.current.isDateInToday(day) ? WarmPalette.peach : .clear, in: Circle()).foregroundStyle(Calendar.current.isDateInToday(day) ? .white : WarmPalette.ink); ForEach(habits.filter { $0.isScheduled(on: day) }) { habit in let key = HabitCompletion(habitID: habit.id, date: day).key; HabitDot(habit: habit, date: day, complete: completions.contains { $0.habitID == habit.id && Calendar.current.isDate($0.date, inSameDayAs: day) }, size: 22, celebrating: key == celebratingKey).onTapGesture(count: 2) { toggle(habit, day) } } }.frame(maxWidth: .infinity).padding(.vertical, 6).background(Calendar.current.isDateInToday(day) ? WarmPalette.peach.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 14)) } }
    }
}

struct MonthCalendarView: View {
    let habits: [Habit]; let completions: [HabitCompletion]; let referenceDate: Date; let toggle: (Habit, Date) -> Void
    var days: [Date?] { let cal = Calendar.current; let range = cal.range(of: .day, in: .month, for: referenceDate)!; let first = cal.date(from: cal.dateComponents([.year,.month], from: referenceDate))!; let pad = (cal.component(.weekday, from: first) + 5) % 7; return Array(repeating: nil, count: pad) + range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: first) } }
    var body: some View {
        VStack(spacing: 5) { HStack { ForEach(["M","T","W","T","F","S","S"].indices, id: \.self) { Text(["M","T","W","T","F","S","S"][$0]).font(.caption2.bold()).foregroundStyle(WarmPalette.muted).frame(maxWidth: .infinity) } }; LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 4) { ForEach(days.indices, id: \.self) { i in if let day = days[i] { VStack(spacing: 3) { Text(day.formatted(.dateTime.day())).font(.caption.bold()); HStack(spacing: 2) { ForEach(habits.filter { $0.isScheduled(on: day) }.prefix(3)) { habit in Circle().fill(completions.contains { $0.habitID == habit.id && Calendar.current.isDate($0.date, inSameDayAs: day) } ? habit.color : .clear).overlay(Circle().stroke(habit.color.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [2]))).frame(width: 7, height: 7) } } }.frame(height: 40).frame(maxWidth: .infinity).background(Calendar.current.isDateInToday(day) ? WarmPalette.peach.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 10)).onTapGesture(count: 2) { if let habit = habits.first(where: { $0.isScheduled(on: day) }) { toggle(habit, day) } } } else { Color.clear.frame(height: 40) } } } }
    }
}
