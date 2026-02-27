import SwiftUI
import Observation

// MARK: - Mood Level

/// Five-point mood scale used for the daily check-in.
enum MoodLevel: Int, CaseIterable, Identifiable, Comparable {
    case veryLow = 1, low = 2, neutral = 3, good = 4, great = 5

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .veryLow: "😢"
        case .low: "😔"
        case .neutral: "😐"
        case .good: "🙂"
        case .great: "😄"
        }
    }

    var label: String {
        switch self {
        case .veryLow: "Very Low"
        case .low: "Low"
        case .neutral: "Neutral"
        case .good: "Good"
        case .great: "Great"
        }
    }

    /// Semantic color used for the corresponding garden flower.
    var color: Color {
        switch self {
        case .veryLow: Color(red: 0.88, green: 0.28, blue: 0.28)
        case .low:     Color(red: 0.95, green: 0.58, blue: 0.18)
        case .neutral: Color(red: 0.95, green: 0.84, blue: 0.18)
        case .good:    Color(red: 0.26, green: 0.84, blue: 0.68)
        case .great:   Color(red: 0.18, green: 0.74, blue: 0.33)
        }
    }

    static func < (lhs: MoodLevel, rhs: MoodLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Wellness Factor

/// Lifestyle factors the user can tag during a check-in.
enum WellnessFactor: String, CaseIterable, Identifiable {
    case sleep, exercise, social, learning, nature, nutrition

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sleep:     "Sleep"
        case .exercise:  "Exercise"
        case .social:    "Social"
        case .learning:  "Learning"
        case .nature:    "Nature"
        case .nutrition: "Nutrition"
        }
    }

    var symbol: String {
        switch self {
        case .sleep:     "moon.stars.fill"
        case .exercise:  "figure.run"
        case .social:    "person.2.fill"
        case .learning:  "book.fill"
        case .nature:    "leaf.fill"
        case .nutrition: "fork.knife"
        }
    }

    var color: Color {
        switch self {
        case .sleep:     .indigo
        case .exercise:  .orange
        case .social:    .pink
        case .learning:  .blue
        case .nature:    .green
        case .nutrition: .mint
        }
    }
}

// MARK: - Breathing Phase

/// One step in the 4-4-6-2 box-breathing cycle.
enum BreathPhase: String, CaseIterable {
    case inhale  = "Inhale"
    case holdIn  = "Hold"
    case exhale  = "Exhale"
    case holdOut = "Rest"

    var instruction: String {
        switch self {
        case .inhale:  "Breathe in slowly…"
        case .holdIn:  "Hold your breath…"
        case .exhale:  "Breathe out gently…"
        case .holdOut: "Rest and pause…"
        }
    }

    /// Seconds this phase should last.
    var duration: Double {
        switch self {
        case .inhale:  4.0
        case .holdIn:  4.0
        case .exhale:  6.0
        case .holdOut: 2.0
        }
    }

    /// Target scale for the breathing circle when this phase is active.
    var targetScale: CGFloat {
        switch self {
        case .inhale, .holdIn:   1.45
        case .exhale, .holdOut:  0.65
        }
    }

    /// Gradient colours applied to the breathing circle.
    var gradientColors: [Color] {
        switch self {
        case .inhale:
            [Color(red: 0.38, green: 0.68, blue: 1.00),
             Color(red: 0.60, green: 0.84, blue: 1.00)]
        case .holdIn:
            [Color(red: 0.50, green: 0.38, blue: 0.92),
             Color(red: 0.70, green: 0.60, blue: 1.00)]
        case .exhale:
            [Color(red: 0.28, green: 0.74, blue: 0.64),
             Color(red: 0.48, green: 0.90, blue: 0.78)]
        case .holdOut:
            [Color(red: 0.58, green: 0.70, blue: 0.86),
             Color(red: 0.74, green: 0.86, blue: 0.96)]
        }
    }

    var next: BreathPhase {
        switch self {
        case .inhale:  .holdIn
        case .holdIn:  .exhale
        case .exhale:  .holdOut
        case .holdOut: .inhale
        }
    }
}

// MARK: - Models

/// A single mood check-in recorded by the user.
struct MoodEntry: Identifiable {
    let id      = UUID()
    let date:    Date
    let mood:    MoodLevel
    let factors: [WellnessFactor]
}

/// One flower in the user's garden, positioned as fractions of the canvas size.
struct GardenFlower: Identifiable {
    let id:          UUID    = UUID()
    let xFraction:   CGFloat          // 0…1
    let yFraction:   CGFloat          // 0…1
    let baseScale:   CGFloat
    let swayOffset:  Double
    let color:       Color
    let petalCount:  Int
    let bloomed:     Bool             // true when mood ≥ neutral
}

// MARK: - Observable Model

@Observable
final class MindBloomModel {

    // MARK: Mood / Garden state
    var entries:        [MoodEntry]          = []
    var flowers:        [GardenFlower]       = []
    var streak:         Int                  = 0
    var checkedInToday: Bool                 = false

    // MARK: Check-in form state
    var selectedMood:    MoodLevel               = .neutral
    var selectedFactors: Set<WellnessFactor>     = []

    // MARK: Breathing state
    var isBreathing:     Bool                = false
    var breathPhase:     BreathPhase         = .inhale
    var completedCycles: Int                 = 0

    // MARK: Navigation
    var activeTab: Int = 0

    // MARK: - Computed

    /// Mean mood value over the last seven entries (1…5 scale).
    var weeklyAverage: Double {
        let recent = Array(entries.prefix(7))
        guard !recent.isEmpty else { return 3.0 }
        return Double(recent.reduce(0) { $0 + $1.mood.rawValue }) / Double(recent.count)
    }

    /// Formatted streak string for display.
    var streakLabel: String { streak == 1 ? "1 day" : "\(streak) days" }

    /// Daily affirmation derived from the calendar day so it rotates naturally.
    var affirmation: String {
        let pool = [
            "You are enough, just as you are.",
            "Every small step forward matters.",
            "Your feelings are valid and real.",
            "You have the strength to bloom.",
            "Today is a fresh beginning.",
            "Be kind and patient with yourself.",
            "You are growing every single day.",
            "Breathe deeply. You've got this."
        ]
        let idx = Calendar.current.component(.day, from: Date()) % pool.count
        return pool[idx]
    }

    // MARK: - Init

    init() { seedSampleData() }

    // MARK: - Garden

    func regenerateFlowers() {
        guard !entries.isEmpty else { flowers = []; return }
        let targetCount = min(entries.count * 2 + 4, 22)
        flowers = (0..<targetCount).map { i in
            let entry = entries[i % entries.count]
            return GardenFlower(
                xFraction:  CGFloat.random(in: 0.04...0.96),
                yFraction:  CGFloat.random(in: 0.22...0.84),
                baseScale:  CGFloat.random(in: 0.60...1.12),
                swayOffset: Double.random(in: -22...22),
                color:      entry.mood.color,
                petalCount: Int.random(in: 5...8),
                bloomed:    entry.mood.rawValue >= 3
            )
        }
    }

    // MARK: - Check-In

    func toggleFactor(_ factor: WellnessFactor) {
        if selectedFactors.contains(factor) {
            selectedFactors.remove(factor)
        } else {
            selectedFactors.insert(factor)
        }
    }

    func submitCheckIn() {
        entries.insert(
            MoodEntry(date: Date(), mood: selectedMood, factors: Array(selectedFactors)),
            at: 0
        )
        checkedInToday  = true
        streak         += 1
        selectedFactors = []
        regenerateFlowers()
        // Navigate back to the garden after a short delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.activeTab = 0
        }
    }

    // MARK: - Breathing

    func startBreathing() {
        breathPhase     = .inhale
        completedCycles = 0
        isBreathing     = true   // triggers the .task in BreatheView
    }

    func stopBreathing() {
        isBreathing = false
    }

    /// Advance to the next breath phase; increments cycle count at wrap-around.
    func advancePhase() {
        let next = breathPhase.next
        if next == .inhale { completedCycles += 1 }
        breathPhase = next
    }

    // MARK: - Sample Data

    private func seedSampleData() {
        let calendar = Calendar.current
        let sampleMoods: [MoodLevel] = [.good, .great, .good, .neutral, .great, .good, .low]
        let sampleFactors: [[WellnessFactor]] = [
            [.exercise, .social],
            [.sleep, .nature],
            [.learning, .nutrition],
            [.sleep],
            [.exercise, .nature, .social],
            [.nutrition, .sleep],
            [.learning, .sleep]
        ]
        for (i, mood) in sampleMoods.enumerated() {
            guard let date = calendar.date(byAdding: .day, value: -(i + 1), to: Date()) else { continue }
            entries.append(MoodEntry(date: date, mood: mood, factors: sampleFactors[i]))
        }
        streak = 7
        regenerateFlowers()
    }
}
