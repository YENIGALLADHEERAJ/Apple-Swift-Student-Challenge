import SwiftUI

// MARK: - Root View ───────────────────────────────────────────────────────────

struct ContentView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        @Bindable var model = model
        TabView(selection: $model.activeTab) {
            GardenView()
                .tabItem { Label("Garden",   systemImage: "leaf.fill") }
                .tag(0)
            CheckInView()
                .tabItem { Label("Check In", systemImage: "heart.fill") }
                .tag(1)
            BreatheView()
                .tabItem { Label("Breathe",  systemImage: "wind") }
                .tag(2)
        }
        .tint(.green)
    }
}

// MARK: - Garden View ─────────────────────────────────────────────────────────

struct GardenView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            gardenCanvas
            statsRow
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: Header

    private var headerBar: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                    Text("MindBloom")
                        .font(.largeTitle.bold())
                }
                Text(model.affirmation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            streakBadge
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("MindBloom garden. Today's affirmation: \(model.affirmation)")
    }

    private var streakBadge: some View {
        VStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .font(.title3)
            Text(model.streakLabel)
                .font(.caption.bold())
                .foregroundStyle(.orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.orange.opacity(0.12), in: .rect(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.orange.opacity(0.3), lineWidth: 1))
        .accessibilityLabel("Current streak")
        .accessibilityValue(model.streakLabel)
        .accessibilityHint("Number of consecutive days you have checked in")
    }

    // MARK: Garden Canvas

    private var gardenCanvas: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                skyGradient
                sunCircle(in: geo)
                grassLayer(in: geo)
                flowersLayer(in: geo)
                if !model.checkedInToday { checkInPrompt }
            }
            .clipShape(.rect(cornerRadius: 24))
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Flower garden")
        .accessibilityValue(
            "\(model.flowers.count) flowers. " +
            (model.checkedInToday ? "You have checked in today." : "Tap 'Check In' to add a new flower.")
        )
    }

    private var skyGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.52, green: 0.81, blue: 0.98),
                Color(red: 0.74, green: 0.94, blue: 0.84)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func sunCircle(in geo: GeometryProxy) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(red: 1.0, green: 0.92, blue: 0.4),
                             Color(red: 1.0, green: 0.75, blue: 0.2).opacity(0)],
                    center: .center, startRadius: 0, endRadius: 50
                )
            )
            .frame(width: 90, height: 90)
            .position(x: geo.size.width * 0.82, y: geo.size.height * 0.16)
    }

    private func grassLayer(in geo: GeometryProxy) -> some View {
        LinearGradient(
            colors: [Color(red: 0.33, green: 0.72, blue: 0.38), Color(red: 0.22, green: 0.60, blue: 0.28)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: geo.size.height * 0.22)
    }

    private func flowersLayer(in geo: GeometryProxy) -> some View {
        ForEach(model.flowers) { flower in
            FlowerView(flower: flower)
                .position(
                    x: geo.size.width  * flower.xFraction,
                    y: geo.size.height * flower.yFraction
                )
        }
    }

    private var checkInPrompt: some View {
        Text("Check in to plant your flower today 🌱")
            .font(.caption.bold())
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(.white.opacity(0.75), in: .capsule)
            .padding(.bottom, 12)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "chart.bar.fill",
                iconColor: .purple,
                title: "Weekly Mood",
                value: String(format: "%.1f / 5.0", model.weeklyAverage)
            )
            .accessibilityLabel("Weekly mood average")
            .accessibilityValue(String(format: "%.1f out of 5.0", model.weeklyAverage))

            StatCard(
                icon: "checkmark.circle.fill",
                iconColor: .green,
                title: "Total Check-Ins",
                value: "\(model.entries.count)"
            )
            .accessibilityLabel("Total check-ins recorded")
            .accessibilityValue("\(model.entries.count)")
        }
        .padding()
    }
}

// MARK: - Stat Card ────────────────────────────────────────────────────────────

struct StatCard: View {
    let icon:      String
    let iconColor: Color
    let title:     String
    let value:     String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.regularMaterial, in: .rect(cornerRadius: 18))
    }
}

// MARK: - Flower View ─────────────────────────────────────────────────────────

struct FlowerView: View {
    let flower: GardenFlower

    @State private var sway:    Double  = 0
    @State private var bloomed: Bool    = false

    var body: some View {
        ZStack {
            // Stem
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(red: 0.28, green: 0.62, blue: 0.32).opacity(0.85))
                .frame(width: 3, height: 24)
                .offset(y: 18)

            // Petals
            ForEach(0..<flower.petalCount, id: \.self) { i in
                Ellipse()
                    .fill(flower.color.opacity(0.90))
                    .frame(width: 11, height: 17)
                    .offset(y: -10)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(flower.petalCount))))
                    .scaleEffect(bloomed ? 1.0 : 0.01)
                    .animation(
                        .spring(response: 0.7, dampingFraction: 0.5)
                            .delay(Double(i) * 0.05 + Double.random(in: 0...0.25)),
                        value: bloomed
                    )
            }

            // Centre circle
            Circle()
                .fill(Color(red: 0.98, green: 0.86, blue: 0.22))
                .frame(width: 10, height: 10)
                .scaleEffect(bloomed ? 1.0 : 0.01)
                .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.15), value: bloomed)
        }
        .scaleEffect(flower.baseScale)
        .rotationEffect(.degrees(sway + flower.swayOffset))
        .onAppear {
            bloomed = true
            withAnimation(
                .easeInOut(duration: Double.random(in: 2.5...4.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...1.5))
            ) {
                sway = Double.random(in: -10...10)
            }
        }
    }
}

// MARK: - Check-In View ───────────────────────────────────────────────────────

struct CheckInView: View {
    @Environment(MindBloomModel.self) private var model
    @State private var submitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if model.checkedInToday {
                        AlreadyCheckedInBanner()
                    } else {
                        moodSection
                        factorsSection
                        submitButton
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: Mood Section

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("How are you feeling?", systemImage: "face.smiling")
                .font(.title2.bold())

            HStack(spacing: 8) {
                ForEach(MoodLevel.allCases) { mood in
                    MoodButton(mood: mood, isSelected: model.selectedMood == mood) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            model.selectedMood = mood
                        }
                    }
                }
            }
        }
    }

    // MARK: Factors Section

    private var factorsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("What's influencing you?", systemImage: "sparkles")
                .font(.title2.bold())

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(WellnessFactor.allCases) { factor in
                    FactorChip(
                        factor:     factor,
                        isSelected: model.selectedFactors.contains(factor)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            model.toggleFactor(factor)
                        }
                    }
                }
            }
        }
    }

    // MARK: Submit Button

    private var submitButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                model.submitCheckIn()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Plant My Flower")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.green, Color(red: 0.18, green: 0.74, blue: 0.55)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 18))
            .shadow(color: .green.opacity(0.35), radius: 8, y: 4)
        }
        .accessibilityLabel("Plant my flower")
        .accessibilityHint("Saves your mood check-in and adds a new flower to your garden")
    }
}

// MARK: - Already Checked-In Banner ──────────────────────────────────────────

struct AlreadyCheckedInBanner: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: true)

            Text("Already checked in today! 🌸")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Come back tomorrow to tend your garden.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(.green.opacity(0.08), in: .rect(cornerRadius: 22))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Already checked in today. Come back tomorrow to tend your garden.")
    }
}

// MARK: - Mood Button ─────────────────────────────────────────────────────────

struct MoodButton: View {
    let mood:       MoodLevel
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Text(mood.emoji)
                    .font(.system(size: 30))
                Text(mood.label)
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? mood.color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected ? mood.color.opacity(0.16) : Color(.secondarySystemGroupedBackground),
                in: .rect(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? mood.color : Color.gray.opacity(0.18), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.06 : 1.0)
        }
        .accessibilityLabel("\(mood.label) mood")
        .accessibilityHint("Tap to select \(mood.label) as your current mood")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Factor Chip ─────────────────────────────────────────────────────────

struct FactorChip: View {
    let factor:     WellnessFactor
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: factor.symbol)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : factor.color)
                Text(factor.label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                factor.color.opacity(isSelected ? 1.0 : 0.10),
                in: .rect(cornerRadius: 14)
            )
            .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .accessibilityLabel(factor.label)
        .accessibilityHint("Double tap to \(isSelected ? "deselect" : "select") \(factor.label)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Breathe View ────────────────────────────────────────────────────────

struct BreatheView: View {
    @Environment(MindBloomModel.self) private var model
    /// Local scale driven by animations so the model stays free of view state.
    @State private var breathScale: CGFloat = 0.65

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 36) {
                headerText
                breathCircle
                if model.isBreathing { cycleCounter }
                controlButton
            }
            .padding(.horizontal, 32)
        }
        // Start animation for the initial phase
        .onChange(of: model.isBreathing) { _, nowBreathing in
            if nowBreathing {
                withAnimation(.easeInOut(duration: BreathPhase.inhale.duration)) {
                    breathScale = BreathPhase.inhale.targetScale
                }
            } else {
                withAnimation(.easeInOut(duration: 0.8)) {
                    breathScale = 0.65
                }
            }
        }
        // Animate scale transition for each subsequent phase
        .onChange(of: model.breathPhase) { _, newPhase in
            withAnimation(.easeInOut(duration: newPhase.duration)) {
                breathScale = newPhase.targetScale
            }
        }
        // Drive the phase timer
        .task(id: model.isBreathing) {
            guard model.isBreathing else { return }
            while model.isBreathing && !Task.isCancelled {
                let phaseDuration = model.breathPhase.duration
                try? await Task.sleep(for: .seconds(phaseDuration))
                guard model.isBreathing && !Task.isCancelled else { break }
                model.advancePhase()
            }
        }
    }

    // MARK: Sub-views

    private var backgroundGradient: some View {
        let colors: [Color] = model.isBreathing
            ? model.breathPhase.gradientColors.map { $0.opacity(0.22) }
            : [Color(red: 0.90, green: 0.95, blue: 1.00),
               Color(red: 0.84, green: 0.92, blue: 0.98)]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.2), value: model.breathPhase)
    }

    private var headerText: some View {
        VStack(spacing: 6) {
            Text("Breathe")
                .font(.largeTitle.bold())
            Text(model.isBreathing ? "4 · 4 · 6 · 2 pattern" : "Box Breathing Exercise")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var breathCircle: some View {
        ZStack {
            // Ambient halo rings
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        (model.isBreathing
                            ? model.breathPhase.gradientColors.first ?? .blue
                            : Color.blue
                        ).opacity(0.12 - Double(i) * 0.03),
                        lineWidth: 1.5
                    )
                    .scaleEffect(breathScale + CGFloat(i + 1) * 0.13)
                    .animation(.easeInOut(duration: model.breathPhase.duration), value: breathScale)
            }

            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: model.isBreathing
                            ? model.breathPhase.gradientColors
                            : [.blue.opacity(0.40), .cyan.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(breathScale)
                .shadow(
                    color: (model.isBreathing
                        ? model.breathPhase.gradientColors.first ?? .blue
                        : .blue
                    ).opacity(0.30),
                    radius: 22
                )
                .animation(.easeInOut(duration: model.breathPhase.duration), value: breathScale)

            // Phase label inside circle
            circleLabel
        }
        .frame(width: 290, height: 290)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            model.isBreathing
                ? "Breathing guide: \(model.breathPhase.rawValue)"
                : "Breathing guide, inactive"
        )
        .accessibilityValue(
            model.isBreathing
                ? model.breathPhase.instruction
                : "Tap Start to begin a guided breathing exercise"
        )
        .accessibilityHint("Visual indicator for the breathing exercise")
    }

    @ViewBuilder
    private var circleLabel: some View {
        if model.isBreathing {
            VStack(spacing: 5) {
                Text(model.breathPhase.rawValue)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(model.breathPhase.instruction)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.92)))
            .animation(.easeInOut(duration: 0.35), value: model.breathPhase)
        } else {
            Image(systemName: "wind")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.80))
        }
    }

    private var cycleCounter: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.circlepath")
                .foregroundStyle(.secondary)
            Text("Cycles completed: \(model.completedCycles)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Completed breathing cycles")
        .accessibilityValue("\(model.completedCycles)")
    }

    private var controlButton: some View {
        Button {
            if model.isBreathing {
                model.stopBreathing()
            } else {
                model.startBreathing()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: model.isBreathing ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2)
                Text(model.isBreathing ? "Stop" : "Start Breathing")
                    .font(.headline)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .background(
                model.isBreathing ? Color.red.opacity(0.12) : Color.blue.opacity(0.12),
                in: .capsule
            )
            .overlay(
                Capsule()
                    .stroke(
                        model.isBreathing ? Color.red.opacity(0.40) : Color.blue.opacity(0.40),
                        lineWidth: 1.5
                    )
            )
            .foregroundStyle(model.isBreathing ? .red : .blue)
        }
        .accessibilityLabel(model.isBreathing ? "Stop breathing exercise" : "Start breathing exercise")
        .accessibilityHint(
            model.isBreathing
                ? "Stops the guided 4-4-6-2 breathing animation"
                : "Starts a guided box-breathing exercise with visual cues"
        )
    }
}

// MARK: - Preview ─────────────────────────────────────────────────────────────

#Preview {
    ContentView()
        .environment(MindBloomModel())
}
