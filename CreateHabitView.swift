import SwiftUI

struct CreateHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: HabitStore
    @State private var name = ""
    @State private var icon = "💧"
    @State private var colorHex = WarmPalette.colors[0]
    @State private var frequency = HabitFrequency.daily
    @State private var weekdays: Set<Int> = [2, 4, 6]
    @State private var count = 3
    @State private var time = HabitTime.morning
    @State private var reminder = false
    @State private var startDate = Date.now
    private let icons = ["💧","📚","🏃","🧘","💊","🍎","☕️","🎸","✍️","🏋️","🚶","🌿","🎯","🧹","💤","🥗","🌅","📓","🎨","🏊","🚴","🧠","🌱","🐕","❤️","⭐️","🔥","🌙","☀️","🌸","🦋","🌊"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 8) {
                        HabitDot(habit: preview, date: .now, complete: false, size: 58)
                        Text(name.isEmpty ? "My Habit" : name).font(.title3.bold()).foregroundStyle(WarmPalette.ink)
                        Text("Tiny steps count ✿").font(.caption).foregroundStyle(WarmPalette.muted)
                    }.frame(maxWidth: .infinity).padding(.vertical, 12)
                }.listRowBackground(WarmPalette.card)
                Section("Habit") {
                    TextField("Habit name", text: $name)
                    Picker("Icon", selection: $icon) { ForEach(icons, id: \.self) { Text($0).tag($0) } }
                    HStack { Text("Color"); Spacer(); ForEach(WarmPalette.colors, id: \.self) { hex in Circle().fill(Color(hex: hex)).frame(width: 25, height: 25).overlay { if colorHex == hex { Image(systemName: "checkmark").font(.caption2.bold()).foregroundStyle(.white) } }.onTapGesture { colorHex = hex } } }
                }
                Section("Frequency") {
                    Picker("Ideal frequency", selection: $frequency) { ForEach(HabitFrequency.allCases) { Text($0.title).tag($0) } }
                    if frequency == .specific {
                        HStack { ForEach(Array(zip([1,2,3,4,5,6,7], ["S","M","T","W","T","F","S"])), id: \.0) { value, label in Text(label).font(.caption.bold()).frame(width: 30, height: 30).background(weekdays.contains(value) ? WarmPalette.peach : Color.secondary.opacity(0.12), in: Circle()).foregroundStyle(weekdays.contains(value) ? .white : WarmPalette.ink).onTapGesture { if weekdays.contains(value) { weekdays.remove(value) } else { weekdays.insert(value) } } } }
                    }
                    if frequency == .weekly || frequency == .monthly { Stepper("\(count) times per \(frequency == .weekly ? "week" : "month")", value: $count, in: 1...31) }
                }
                Section("Routine") {
                    Picker("Time of day", selection: $time) { ForEach(HabitTime.allCases) { Label($0.title, systemImage: $0.symbol).tag($0) } }
                    Toggle("Gentle reminder", isOn: $reminder)
                    DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                }
            }
            .scrollContentBackground(.hidden).background(WarmPalette.background)
            .navigationTitle("New Habit").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).bold().disabled(name.trimmingCharacters(in: .whitespaces).isEmpty) } }
        }.tint(WarmPalette.peach)
    }

    private var preview: Habit { Habit(name: name.isEmpty ? "My Habit" : name, icon: icon, colorHex: colorHex, frequency: frequency, weekdays: weekdays, frequencyCount: count, time: time, reminder: reminder, startDate: startDate) }
    private func save() { let habit = Habit(name: name.trimmingCharacters(in: .whitespaces), icon: icon, colorHex: colorHex, frequency: frequency, weekdays: weekdays, frequencyCount: count, time: time, reminder: reminder, startDate: startDate); store.add(habit); dismiss() }
}
