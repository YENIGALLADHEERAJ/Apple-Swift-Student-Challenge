import SwiftUI
import Foundation

// MARK: - MoodLevel

enum MoodLevel: Int, CaseIterable, Identifiable, Codable {
    case veryLow = 1, low, neutral, high, veryHigh

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .veryLow:  return "😞"
        case .low:      return "😕"
        case .neutral:  return "😐"
        case .high:     return "🙂"
        case .veryHigh: return "😄"
        }
    }

    var label: String {
        switch self {
        case .veryLow:  return "Very Low"
        case .low:      return "Low"
        case .neutral:  return "Neutral"
        case .high:     return "High"
        case .veryHigh: return "Very High"
        }
    }

    var petalColor: Color {
        switch self {
        case .veryLow:  return Color(red: 0.55, green: 0.60, blue: 0.80)
        case .low:      return Color(red: 0.55, green: 0.78, blue: 0.88)
        case .neutral:  return Color(red: 0.55, green: 0.85, blue: 0.70)
        case .high:     return Color(red: 1.00, green: 0.84, blue: 0.40)
        case .veryHigh: return Color(red: 1.00, green: 0.60, blue: 0.45)
        }
    }

    var accentColor: Color {
        switch self {
        case .veryLow:  return Color(red: 0.35, green: 0.38, blue: 0.65)
        case .low:      return Color(red: 0.25, green: 0.55, blue: 0.75)
        case .neutral:  return Color(red: 0.20, green: 0.65, blue: 0.45)
        case .high:     return Color(red: 0.85, green: 0.65, blue: 0.10)
        case .veryHigh: return Color(red: 0.90, green: 0.35, blue: 0.20)
        }
    }
}

// MARK: - WellnessFactor

enum WellnessFactor: String, CaseIterable, Identifiable, Codable {
    case sleep, exercise, social, nutrition, nature, gratitude

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sleep:      return "moon.zzz.fill"
        case .exercise:   return "figure.run"
        case .social:     return "person.2.fill"
        case .nutrition:  return "fork.knife"
        case .nature:     return "leaf.fill"
        case .gratitude:  return "heart.fill"
        }
    }

    var label: String { rawValue.capitalized }

    var chipColor: Color {
        switch self {
        case .sleep:      return Color(red: 0.40, green: 0.45, blue: 0.85)
        case .exercise:   return Color(red: 0.25, green: 0.75, blue: 0.55)
        case .social:     return Color(red: 0.95, green: 0.55, blue: 0.30)
        case .nutrition:  return Color(red: 0.30, green: 0.78, blue: 0.40)
        case .nature:     return Color(red: 0.20, green: 0.70, blue: 0.30)
        case .gratitude:  return Color(red: 0.90, green: 0.35, blue: 0.55)
        }
    }
}

// MARK: - BreathPhase

enum BreathPhase: String, CaseIterable {
    case idle, inhale, holdIn, exhale, holdOut, complete

    var duration: Double {
        switch self {
        case .idle:     return 0
        case .inhale:   return 4
        case .holdIn:   return 4
        case .exhale:   return 6
        case .holdOut:  return 2
        case .complete: return 0
        }
    }

    var targetScale: CGFloat {
        switch self {
        case .idle:     return 1.0
        case .inhale:   return 1.6
        case .holdIn:   return 1.6
        case .exhale:   return 1.0
        case .holdOut:  return 1.0
        case .complete: return 1.0
        }
    }

    var instruction: String {
        switch self {
        case .idle:     return "Tap Begin to start"
        case .inhale:   return "Breathe In"
        case .holdIn:   return "Hold"
        case .exhale:   return "Breathe Out"
        case .holdOut:  return "Hold"
        case .complete: return "Well done"
        }
    }

    var next: BreathPhase {
        switch self {
        case .idle:     return .inhale
        case .inhale:   return .holdIn
        case .holdIn:   return .exhale
        case .exhale:   return .holdOut
        case .holdOut:  return .inhale
        case .complete: return .idle
        }
    }
}

// MARK: - MoodEntry

struct MoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var mood: MoodLevel
    var factors: Set<WellnessFactor>
    var note: String = ""
}

// MARK: - GardenFlower

struct GardenFlower: Identifiable {
    var id: UUID = UUID()
    var position: CGPoint      // normalised 0–1
    var scale: CGFloat
    var swayOffset: CGFloat
    var bloomProgress: CGFloat
    var mood: MoodLevel
}

// MARK: - MindBloomModel

@Observable
class MindBloomModel {

    // MARK: Persisted entries
    var entries: [MoodEntry] = [] {
        didSet { saveEntries() }
    }

    // MARK: Garden
    var gardenFlowers: [GardenFlower] = []

    // MARK: Check-in transient state
    var selectedMood: MoodLevel? = nil
    var selectedFactors: Set<WellnessFactor> = []
    var noteText: String = ""
    var showSuccessBanner: Bool = false

    // MARK: Breathe state (model owns only these three)
    var breathPhase: BreathPhase = .idle
    var isBreathing: Bool = false
    var cyclesCompleted: Int = 0

    // MARK: - Computed

    var hasCheckedInToday: Bool {
        guard let last = entries.last else { return false }
        return Calendar.current.isDateInToday(last.date)
    }

    var streak: Int {
        guard !entries.isEmpty else { return 0 }
        var count = 0
        var checkDate = Calendar.current.startOfDay(for: Date())
        let sortedEntries = entries.sorted { $0.date > $1.date }
        for entry in sortedEntries {
            let entryDay = Calendar.current.startOfDay(for: entry.date)
            if entryDay == checkDate {
                count += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if entryDay < checkDate {
                break
            }
        }
        return count
    }

    var weeklyAverage: Double? {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recent = entries.filter { $0.date >= weekAgo }
        guard !recent.isEmpty else { return nil }
        let sum = recent.reduce(0) { $0 + $1.mood.rawValue }
        return Double(sum) / Double(recent.count)
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning 🌅"
        case 12..<17: return "Good Afternoon ☀️"
        case 17..<21: return "Good Evening 🌇"
        default:      return "Good Night 🌙"
        }
    }

    // MARK: - Init

    init() {
        loadEntries()
        regenerateFlowers()
    }

    // MARK: - Check-in

    func submitCheckIn() {
        guard let mood = selectedMood else { return }
        let entry = MoodEntry(
            date: Date(),
            mood: mood,
            factors: selectedFactors,
            note: noteText
        )
        entries.append(entry)
        regenerateFlowers()
        // Reset
        selectedMood = nil
        selectedFactors = []
        noteText = ""
        showSuccessBanner = true
    }

    // MARK: - Garden

    func regenerateFlowers() {
        guard !entries.isEmpty else {
            gardenFlowers = []
            return
        }
        gardenFlowers = entries.enumerated().map { index, entry in
            let pos = layoutPosition(index: index, total: entries.count)
            return GardenFlower(
                position: pos,
                scale: CGFloat.random(in: 0.7...1.2),
                swayOffset: CGFloat.random(in: -8...8),
                bloomProgress: 1.0,
                mood: entry.mood
            )
        }
    }

    func layoutPosition(index: Int, total: Int) -> CGPoint {
        guard total > 0 else { return CGPoint(x: 0.5, y: 0.7) }
        let columns = max(1, Int(ceil(sqrt(Double(total)))))
        let col = index % columns
        let row = index / columns
        let totalRows = max(1, Int(ceil(Double(total) / Double(columns))))
        let xBase = (Double(col) + 0.5) / Double(columns)
        let yBase = 0.45 + (Double(row) / Double(max(1, totalRows))) * 0.45
        let jitterX = Double.random(in: -0.04...0.04)
        let jitterY = Double.random(in: -0.03...0.03)
        return CGPoint(
            x: min(max(xBase + jitterX, 0.05), 0.95),
            y: min(max(yBase + jitterY, 0.40), 0.90)
        )
    }

    // MARK: - Breathe

    func startBreathing() {
        cyclesCompleted = 0
        isBreathing = true
        breathPhase = .idle
    }

    func stopBreathing() {
        isBreathing = false
        breathPhase = .idle
    }

    func advanceBreathPhase() {
        let next = breathPhase.next
        if next == .inhale && breathPhase == .holdOut {
            cyclesCompleted += 1
            if cyclesCompleted >= 4 {
                breathPhase = .complete
                isBreathing = false
                return
            }
        }
        breathPhase = next
    }

    // MARK: - Persistence

    private var persistenceURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("mindbloom_entries.json")
    }

    private func saveEntries() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: persistenceURL)
    }

    private func loadEntries() {
        guard
            let data = try? Data(contentsOf: persistenceURL),
            let loaded = try? JSONDecoder().decode([MoodEntry].self, from: data)
        else { return }
        entries = loaded
    }
}
