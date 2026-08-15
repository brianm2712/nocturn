import Foundation

struct ConnectionSettings: Equatable {
    var host: String
    var port: Int
    var manualToken: String
    var pollSeconds: Double
    var demoMode: Bool

    var baseURL: URL { URL(string: "http://\(host):\(port)")! }

    static func load(defaults: UserDefaults = .standard) -> ConnectionSettings {
        ConnectionSettings(
            host: defaults.string(forKey: "host") ?? "127.0.0.1",
            port: defaults.object(forKey: "port") as? Int ?? 9119,
            manualToken: defaults.string(forKey: "manualToken") ?? "",
            pollSeconds: defaults.object(forKey: "pollSeconds") as? Double ?? 10,
            demoMode: defaults.bool(forKey: "demoMode"))
    }

    func save(defaults: UserDefaults = .standard) {
        defaults.set(host, forKey: "host")
        defaults.set(port, forKey: "port")
        defaults.set(manualToken, forKey: "manualToken")
        defaults.set(pollSeconds, forKey: "pollSeconds")
        defaults.set(demoMode, forKey: "demoMode")
    }
}
