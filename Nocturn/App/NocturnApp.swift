import SwiftUI

@main
struct NocturnApp: App {
    @State private var store = MonitorStore(settings: .load())

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(store)
                .task { await store.start() }
        }
        #if os(macOS)
        .defaultSize(width: 720, height: 520)
        #endif
    }
}
