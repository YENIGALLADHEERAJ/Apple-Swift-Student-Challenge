import SwiftUI

/// MindBloom – Apple Swift Student Challenge 2025
///
/// Idea: A mental-wellness garden where each daily mood check-in
/// plants a new flower. The garden grows richer as the user builds
/// healthy habits, making abstract emotional data delightfully
/// tangible. Three tabs — Garden, Check-In, and Breathe — guide the
/// user through reflection, awareness, and calm in under 3 minutes.
///
/// Design philosophy alignment:
///   • Personal & meaningful data visualisation (garden metaphor)
///   • Privacy-first: all data lives on-device
///   • Delightful micro-animations reinforce positive actions
///   • Full Dynamic Type and VoiceOver accessibility

@main
struct MindBloomApp: App {

    @State private var model = MindBloomModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }
    }
}
