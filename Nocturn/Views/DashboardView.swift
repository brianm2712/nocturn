import SwiftUI

struct DashboardView: View {
    @Environment(MonitorStore.self) private var store
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            HealthStrip(state: store.state)
            content
        }
        .background(Theme.background)
        .toolbar {
            ToolbarItem {
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    @ViewBuilder private var content: some View {
        GeometryReader { geo in
            ScrollView {
                if geo.size.width > 560 {
                    // Mac / iPad: 2-column grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: Theme.gridSpacing),
                                        GridItem(.flexible())],
                              spacing: Theme.gridSpacing) {
                        LiveAgentsCard(state: store.state)
                        UsageCard(state: store.state)
                        ErrorsCard(state: store.state)
                        TasksCronCard(state: store.state)
                    }
                    .padding(Theme.gridSpacing)
                } else {
                    // iPhone: stacked
                    VStack(spacing: Theme.gridSpacing) {
                        LiveAgentsCard(state: store.state)
                        UsageCard(state: store.state)
                        ErrorsCard(state: store.state)
                        TasksCronCard(state: store.state)
                    }
                    .padding(Theme.gridSpacing)
                }
            }
        }
    }
}

#Preview {
    let store = MonitorStore(settings: ConnectionSettings(
        host: "127.0.0.1", port: 9119, manualToken: "",
        pollSeconds: 10, demoMode: true))
    store.state = DemoData.state
    return DashboardView().environment(store)
}
