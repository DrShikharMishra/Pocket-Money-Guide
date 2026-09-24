import SwiftUI
import SwiftData

@main
struct PocketMoneyGuideApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Transaction.self, Budget.self])
    }
}
