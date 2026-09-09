import Foundation
import SwiftUI

enum HabitFrequency: String, Codable, CaseIterable, Identifiable {
    case daily, weekdays, specific, weekly, monthly
    var id: String { rawValue }
    var title: String {
        switch self {
        case .daily: "Every day"
        case .weekdays: "Weekdays"
        case .specific: "Specific days"
        case .weekly: "Times per week"
        case .monthly: "Times per month"
        }
    }
}

enum HabitTime: String, Codable, CaseIterable, Identifiable {
    case morning, afternoon, evening, anytime
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var symbol: String { switch self { case .morning: "sunrise.fill"; case .afternoon: "sun.max.fill"; case .evening: "moon.stars.fill"; case .anytime: "clock.fill" } }
}

struct Habit: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var frequencyRaw: String
    var weekdaysData: Data
    var frequencyCount: Int
    var timeRaw: String
    var reminder: Bool
    var startDate: Date
    var createdAt: Date

    init(name: String, icon: String, colorHex: String, frequency: HabitFrequency = .daily,
         weekdays: Set<Int> = [2, 4, 6], frequencyCount: Int = 3,
         time: HabitTime = .morning, reminder: Bool = false, startDate: Date = .now) {
        id = UUID(); self.name = name; self.icon = icon; self.colorHex = colorHex
        frequencyRaw = frequency.rawValue
        weekdaysData = (try? JSONEncoder().encode(weekdays)) ?? Data()
        self.frequencyCount = frequencyCount; timeRaw = time.rawValue
        self.reminder = reminder; self.startDate = Calendar.current.startOfDay(for: startDate); createdAt = .now
    }

    var frequency: HabitFrequency { get { HabitFrequency(rawValue: frequencyRaw) ?? .daily } set { frequencyRaw = newValue.rawValue } }
    var time: HabitTime { get { HabitTime(rawValue: timeRaw) ?? .anytime } set { timeRaw = newValue.rawValue } }
    var weekdays: Set<Int> { get { (try? JSONDecoder().decode(Set<Int>.self, from: weekdaysData)) ?? [] } set { weekdaysData = (try? JSONEncoder().encode(newValue)) ?? Data() } }
    var color: Color { Color(hex: colorHex) }

    func isScheduled(on date: Date) -> Bool {
        let cal = Calendar.current, day = cal.startOfDay(for: date)
        guard day >= cal.startOfDay(for: startDate) else { return false }
        let weekday = cal.component(.weekday, from: day)
        switch frequency {
        case .daily: return true
        case .weekdays: return (2...6).contains(weekday)
        case .specific: return weekdays.contains(weekday)
        case .weekly, .monthly: return true
        }
    }
}

struct HabitCompletion: Codable, Identifiable, Hashable {
    var id: String { key }
    var key: String
    var habitID: UUID
    var date: Date
    init(habitID: UUID, date: Date) {
        self.habitID = habitID; self.date = Calendar.current.startOfDay(for: date)
        key = "\(habitID.uuidString)-\(Self.dayKey(date))"
    }
    static func dayKey(_ date: Date) -> String {
        let f = DateFormatter(); f.calendar = .current; f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0; Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count { case 3: (r,g,b) = ((int>>8)*17, (int>>4&0xF)*17, (int&0xF)*17); default: (r,g,b) = (int>>16, int>>8&0xFF, int&0xFF) }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1)
    }
}

enum WarmPalette {
    static let background = Color(hex: "FFF8EF")
    static let card = Color(hex: "FFFDFC")
    static let ink = Color(hex: "42352F")
    static let muted = Color(hex: "9A8378")
    static let peach = Color(hex: "F49A79")
    static let colors = ["F49A79", "F4BE65", "A7C6A0", "D49AAF", "91B8C4", "C7A4D6", "E88478", "B7A274"]
}
