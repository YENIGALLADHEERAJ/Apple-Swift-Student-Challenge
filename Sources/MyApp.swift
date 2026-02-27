import SwiftUI

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
