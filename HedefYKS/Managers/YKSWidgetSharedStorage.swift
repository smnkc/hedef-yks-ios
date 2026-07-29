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
    let examTimestamp: Double?
}

class YKSWidgetSharedStorage {
    static let shared = YKSWidgetSharedStorage()
    private let appGroupID = "group.com.smnkc.HedefYKS"
    private let userDefaultsKey = "shared_widget_data_key"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    private var fileURL: URL? {
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            return container.appendingPathComponent("widget_data.json")
        }
        return nil
    }
    
    func save(data: SharedWidgetData) {
        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults?.set(encoded, forKey: userDefaultsKey)
            sharedDefaults?.synchronize()
            if let fileURL = fileURL {
                try? encoded.write(to: fileURL, options: .atomic)
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func load() -> SharedWidgetData? {
        if let data = sharedDefaults?.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(SharedWidgetData.self, from: data) {
            return decoded
        }
        if let fileURL = fileURL,
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(SharedWidgetData.self, from: data) {
            return decoded
        }
        return nil
    }
}

