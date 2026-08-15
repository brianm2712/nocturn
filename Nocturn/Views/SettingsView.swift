import SwiftUI

struct SettingsView: View {
    @Environment(MonitorStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ConnectionSettings.load()

    var body: some View {
        Form {
            Section("Hermes Dashboard") {
                TextField("Host", text: $draft.host)
                TextField("Port", value: $draft.port, format: .number)
                SecureField("Session token (optional)", text: $draft.manualToken)
                Text("Leave the token empty on the same Mac — Nocturn reads it from the dashboard automatically. From iPhone/iPad, start the dashboard bound to your LAN and both devices must share a network (or Tailscale).")
                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
            }
            Section("Refresh") {
                Stepper("Every \(Int(draft.pollSeconds))s",
                        value: $draft.pollSeconds, in: 3...120, step: 1)
            }
            Section {
                Toggle("Demo mode (sample data)", isOn: $draft.demoMode)
            }
            Button("Save") {
                store.settings = draft
                dismiss()
            }
        }
        .formStyle(.grouped)
        #if os(macOS)
        .frame(width: 420, height: 380)
        #endif
    }
}
