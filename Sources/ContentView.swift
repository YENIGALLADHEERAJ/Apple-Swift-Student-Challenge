import SwiftUI

// MARK: - Root Content View

struct ContentView: View {
    @Environment(MindBloomModel.self) private var model
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GardenView()
                .tabItem {
                    Label("Garden", systemImage: "leaf.fill")
                }
                .tag(0)

            CheckInView()
                .tabItem {
                    Label("Check In", systemImage: "plus.circle.fill")
                }
                .tag(1)

            BreatheView()
                .tabItem {
                    Label("Breathe", systemImage: "wind")
                }
                .tag(2)
        }
        .tint(.green)
    }
}

// MARK: - GARDEN TAB

struct GardenView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        ZStack(alignment: .bottom) {
            // Sky gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.53, green: 0.81, blue: 0.98),
                    Color(red: 0.87, green: 0.95, blue: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: 0) {
                    // Header
                    GardenHeaderView()
                        .padding(.top, geo.safeAreaInsets.top + 8)
                        .padding(.horizontal, 20)

                    // Garden canvas
                    GardenCanvasView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Animated grass strip
                    GrassStripView()
                        .frame(height: 60)
                }
            }
        }
    }
}

// MARK: GardenHeaderView

struct GardenHeaderView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.greetingText)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Text("Your living mood garden")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .symbolEffect(.bounce)
                        .foregroundStyle(.orange)
                    Text("\(model.streak)")
                        .font(.subheadline.bold())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.orange.opacity(0.15), in: Capsule())

                // Weekly average badge
                if let avg = model.weeklyAverage {
                    let avgMood = MoodLevel.allCases.min(by: {
                        abs(Double($0.rawValue) - avg) < abs(Double($1.rawValue) - avg)
                    })!
                    HStack(spacing: 4) {
                        Text(avgMood.emoji)
                        Text(String(format: "%.1f avg", avg))
                            .font(.subheadline.bold())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.yellow.opacity(0.15), in: Capsule())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: GardenCanvasView

struct GardenCanvasView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if model.gardenFlowers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf")
                            .font(.system(size: 48))
                            .foregroundStyle(.green.opacity(0.5))
                        Text("Check in to plant your first flower!")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(model.gardenFlowers) { flower in
                        FlowerView(flower: flower)
                            .position(
                                x: flower.position.x * geo.size.width,
                                y: flower.position.y * geo.size.height
                            )
                    }
                }
            }
        }
    }
}

// MARK: FlowerView

struct FlowerView: View {
    let flower: GardenFlower
    @State private var bloom: CGFloat = 0
    @State private var sway: CGFloat = 0

    var body: some View {
        ZStack {
            // Stem
            Capsule()
                .fill(Color(red: 0.30, green: 0.65, blue: 0.30))
                .frame(width: 4, height: 36 * flower.scale)
                .offset(y: 20 * flower.scale)

            // Petals
            ForEach(0..<6, id: \.self) { index in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [flower.mood.petalColor.opacity(0.9),
                                     flower.mood.petalColor.opacity(0.4)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 12
                        )
                    )
                    .frame(
                        width: 14 * flower.scale * bloom,
                        height: 22 * flower.scale * bloom
                    )
                    .offset(y: -12 * flower.scale * bloom)
                    .rotationEffect(.degrees(Double(index) * 60))
            }

            // Center
            Circle()
                .fill(flower.mood.accentColor)
                .frame(width: 10 * flower.scale * bloom, height: 10 * flower.scale * bloom)
        }
        .rotationEffect(.degrees(Double(sway)))
        .animation(
            .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
            value: sway
        )
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.55)) {
                bloom = flower.bloomProgress
            }
            sway = flower.swayOffset / 5
        }
    }
}

// MARK: GrassStripView

struct GrassStripView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let phaseOffset = 0.47  // unique starting phase per blade
                let swaySpeed = 0.40    // oscillation rate in radians/second
                for i in 0..<40 {
                    let x = (Double(i) / 39.0) * size.width
                    let direction = Double(i % 3 == 0 ? 1 : -1)
                    let phase = Double(i) * phaseOffset + time * direction * swaySpeed
                    let swayAmount = sin(phase) * 7.0
                    let blade = GrassBlade(swayAmount: swayAmount)
                    let path = blade.path(in: CGRect(
                        x: x - 4, y: 0, width: 8, height: size.height
                    ))
                    context.fill(
                        path,
                        with: .color(Color(
                            red: 0.20 + Double(i % 5) * 0.04,
                            green: 0.52 + Double(i % 3) * 0.06,
                            blue: 0.18
                        ).opacity(0.88))
                    )
                }
            }
        }
        .background(Color(red: 0.25, green: 0.58, blue: 0.18))
    }
}

// MARK: GrassBlade Shape

struct GrassBlade: Shape {
    var swayAmount: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let base = CGPoint(x: rect.midX, y: rect.maxY)
        let tip = CGPoint(
            x: rect.midX + CGFloat(swayAmount),
            y: rect.minY
        )
        let control = CGPoint(
            x: rect.midX + CGFloat(swayAmount) * 0.6,
            y: rect.midY
        )
        path.move(to: CGPoint(x: base.x - 2, y: base.y))
        path.addQuadCurve(
            to: tip,
            control: CGPoint(x: control.x - 2, y: control.y)
        )
        path.addLine(to: tip)
        path.addQuadCurve(
            to: CGPoint(x: base.x + 2, y: base.y),
            control: CGPoint(x: control.x + 2, y: control.y)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - CHECK-IN TAB

struct CheckInView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 24) {
                    if model.hasCheckedInToday {
                        AlreadyCheckedInView()
                    } else {
                        Text("How are you feeling?")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)

                        MoodSelectorView()

                        if model.selectedMood != nil {
                            WellnessFactorView()
                            NoteFieldView()
                            SubmitButton()
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
            }

            if model.showSuccessBanner {
                SuccessBannerView()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(2.5))
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                                model.showSuccessBanner = false
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.70), value: model.showSuccessBanner)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: AlreadyCheckedInView

struct AlreadyCheckedInView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .symbolEffect(.bounce)
                .foregroundStyle(.green)
            Text("All done for today!")
                .font(.title2.bold())
            Text("Your flower has been planted in the garden. Come back tomorrow 🌸")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: MoodSelectorView

struct MoodSelectorView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        HStack(spacing: 10) {
            ForEach(MoodLevel.allCases) { level in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                        model.selectedMood = level
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(level.emoji)
                            .font(.system(size: model.selectedMood == level ? 36 : 28))
                            .animation(.spring(response: 0.35, dampingFraction: 0.70),
                                       value: model.selectedMood)
                        Text(level.label)
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        model.selectedMood == level
                            ? level.petalColor.opacity(0.25)
                            : Color(.systemGray6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                model.selectedMood == level
                                    ? level.accentColor
                                    : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .scaleEffect(model.selectedMood == level ? 1.05 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.70),
                               value: model.selectedMood)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: WellnessFactorView

struct WellnessFactorView: View {
    @Environment(MindBloomModel.self) private var model

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What contributed?")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(WellnessFactor.allCases) { factor in
                    let selected = model.selectedFactors.contains(factor)
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                            if selected {
                                model.selectedFactors.remove(factor)
                            } else {
                                model.selectedFactors.insert(factor)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: factor.icon)
                                .font(.caption)
                            Text(factor.label)
                                .font(.caption.bold())
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            selected
                                ? factor.chipColor.opacity(0.25)
                                : Color(.systemGray6)
                        )
                        .foregroundStyle(selected ? factor.chipColor : .secondary)
                        .overlay(
                            Capsule().stroke(
                                selected ? factor.chipColor : Color.clear,
                                lineWidth: 1.5
                            )
                        )
                        .clipShape(Capsule())
                        .scaleEffect(selected ? 1.04 : 1.0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.70), value: selected)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: NoteFieldView

struct NoteFieldView: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        @Bindable var bindableModel = model
        VStack(alignment: .leading, spacing: 8) {
            Text("Add a note (optional)")
                .font(.headline)
            TextField(
                "What's on your mind?",
                text: $bindableModel.noteText,
                axis: .vertical
            )
            .lineLimit(3...5)
            .padding(12)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: SubmitButton

struct SubmitButton: View {
    @Environment(MindBloomModel.self) private var model
    @State private var didSubmit = false

    var enabled: Bool { model.selectedMood != nil }

    var body: some View {
        Button {
            guard enabled else { return }
            didSubmit = true
            withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                model.submitCheckIn()
            }
        } label: {
            Text("Plant My Flower 🌸")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    enabled
                        ? AnyShapeStyle(LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                          ))
                        : AnyShapeStyle(Color(.systemGray4))
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!enabled)
        .sensoryFeedback(.success, trigger: didSubmit)
    }
}

// MARK: SuccessBannerView

struct SuccessBannerView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
            Text("Flower planted! Your garden is growing 🌺")
                .font(.subheadline.bold())
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 8)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// MARK: - BREATHE TAB

struct BreatheView: View {
    @Environment(MindBloomModel.self) private var model
    @State private var breathScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Dark navy gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.18),
                    Color(red: 0.08, green: 0.12, blue: 0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                // Title
                Text("Box Breathing")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.9))

                // Breathing orb + glow rings
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                orbColor.opacity(0.15 - Double(ring) * 0.04),
                                lineWidth: CGFloat(ring + 1) * 2
                            )
                            .frame(
                                width: 120 + CGFloat(ring + 1) * 28 * breathScale,
                                height: 120 + CGFloat(ring + 1) * 28 * breathScale
                            )
                    }

                    // Main orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [orbColor.opacity(0.95), orbColor.opacity(0.4)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(
                            width: 120 * breathScale,
                            height: 120 * breathScale
                        )

                    // Phase label inside orb
                    Text(model.breathPhase.instruction)
                        .font(.system(size: 14 * breathScale, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .scaleEffect(breathScale)
                }
                .frame(height: 260)

                // Instruction text
                Text(phaseSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.70))
                    .animation(.easeInOut(duration: 0.4), value: model.breathPhase)

                // Cycle counter
                if model.isBreathing || model.cyclesCompleted > 0 {
                    Text("\(model.cyclesCompleted)/4 cycles")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.50))
                }

                // Control button
                BreatheControlButton()
            }
            .padding(32)
        }
        .onChange(of: model.isBreathing) { _, newValue in
            if newValue {
                // Fire the FIRST inhale animation
                Task {
                    try? await Task.sleep(for: .milliseconds(50))
                    model.breathPhase = .inhale
                }
            } else {
                withAnimation(.easeInOut(duration: 0.8)) {
                    breathScale = 1.0
                }
            }
        }
        .onChange(of: model.breathPhase) { _, phase in
            guard phase != .idle else { return }
            withAnimation(.easeInOut(duration: phase.duration)) {
                breathScale = phase.targetScale
            }
        }
        .task(id: model.breathPhase) {
            guard model.breathPhase != .idle, model.breathPhase != .complete else { return }
            let dur = model.breathPhase.duration
            guard dur > 0 else { return }
            try? await Task.sleep(for: .seconds(dur))
            guard model.isBreathing else { return }
            model.advanceBreathPhase()
        }
    }

    private var orbColor: Color {
        switch model.breathPhase {
        case .idle, .complete: return Color(red: 0.35, green: 0.55, blue: 0.90)
        case .inhale:          return Color(red: 0.40, green: 0.75, blue: 0.95)
        case .holdIn:          return Color(red: 0.55, green: 0.80, blue: 0.60)
        case .exhale:          return Color(red: 0.75, green: 0.55, blue: 0.90)
        case .holdOut:         return Color(red: 0.55, green: 0.55, blue: 0.90)
        }
    }

    private var phaseSubtitle: String {
        switch model.breathPhase {
        case .idle:     return "4-4-6-2 Box Breathing · 4 cycles"
        case .inhale:   return "Breathe in slowly for 4 seconds"
        case .holdIn:   return "Hold your breath for 4 seconds"
        case .exhale:   return "Exhale slowly for 6 seconds"
        case .holdOut:  return "Hold empty for 2 seconds"
        case .complete: return "Session complete — great work! 🎉"
        }
    }
}

// MARK: BreatheControlButton

struct BreatheControlButton: View {
    @Environment(MindBloomModel.self) private var model

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                if model.isBreathing {
                    model.stopBreathing()
                } else {
                    model.startBreathing()
                }
            }
        } label: {
            Text(model.isBreathing ? "Stop" : "Begin")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 140, height: 50)
                .background(
                    model.isBreathing
                        ? Color(red: 0.70, green: 0.25, blue: 0.25)
                        : Color(red: 0.25, green: 0.55, blue: 0.90)
                )
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 8)
        }
        .symbolEffect(.bounce, value: model.isBreathing)
    }
}
