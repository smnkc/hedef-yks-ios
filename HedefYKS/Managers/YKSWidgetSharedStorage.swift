import Foundation
import WidgetKit

struct SharedWidgetData: Codable {
    let daysRemaining: Int
    let overallPercentage: Int
    let completedCount: Int
    let totalCount: Int
    let unstartedCount: Int
    let targetYear: Int
    let fieldTitle: String
    let themeColorHex: String
}

class YKSWidgetSharedStorage {
    static let shared = YKSWidgetSharedStorage()
    
    private var fileURL: URL {
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.smnkc.HedefYKS") {
            return container.appendingPathComponent("widget_data.json")
        }
        return URL(fileURLWithPath: "/tmp/hedef_yks_shared_widget_data.json")
    }
    
    func save(data: SharedWidgetData) {
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: fileURL, options: .atomic)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func load() -> SharedWidgetData? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(SharedWidgetData.self, from: data)
    }
}
