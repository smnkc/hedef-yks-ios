import WidgetKit
import SwiftUI

// MARK: - Widget Veri Modeli
struct YKSWidgetEntry: TimelineEntry {
    let date: Date
    let daysRemaining: Int
    let overallPercentage: Int
    let completedCount: Int
    let totalCount: Int
    let targetYear: Int
    let fieldTitle: String
    let themeColorHex: String
    
    var themeColor: Color {
        Color(hex: themeColorHex)
    }
}

// MARK: - Widget Provider (Veri Sağlayıcı)
struct YKSWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> YKSWidgetEntry {
        YKSWidgetEntry(
            date: Date(),
            daysRemaining: 326,
            overallPercentage: 0,
            completedCount: 0,
            totalCount: 94,
            targetYear: 2027,
            fieldTitle: "Sayısal",
            themeColorHex: "3B82F6"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (YKSWidgetEntry) -> Void) {
        completion(fetchCurrentData())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<YKSWidgetEntry>) -> Void) {
        var entries: [YKSWidgetEntry] = []
        let currentDate = Date()
        let shared = YKSWidgetSharedStorage.shared.load()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let targetYear = month >= 7 ? year + 1 : year
        
        let examDate: Date
        if let timestamp = shared?.examTimestamp {
            examDate = Date(timeIntervalSince1970: timestamp)
        } else {
            var components = DateComponents()
            components.year = targetYear
            components.month = 6
            components.day = 19
            components.hour = 10
            components.minute = 15
            examDate = calendar.date(from: components) ?? currentDate
        }
        
        // Önümüzdeki 7 gün için her gece yarısı otomatik düşecek zaman çizelgesi girdileri üret
        for dayOffset in 0..<7 {
            guard let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: currentDate) else { continue }
            let days = max(0, calendar.dateComponents([.day], from: entryDate, to: examDate).day ?? 0)
            
            let entry = YKSWidgetEntry(
                date: entryDate,
                daysRemaining: days,
                overallPercentage: shared?.overallPercentage ?? 0,
                completedCount: shared?.completedCount ?? 0,
                totalCount: shared?.totalCount ?? 100,
                targetYear: shared?.targetYear ?? targetYear,
                fieldTitle: shared?.fieldTitle ?? "Sayısal",
                themeColorHex: shared?.themeColorHex ?? "3B82F6"
            )
            entries.append(entry)
        }

        let nextUpdate = calendar.date(byAdding: .day, value: 7, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchCurrentData() -> YKSWidgetEntry {
        let calendar = Calendar.current
        let now = Date()
        let shared = YKSWidgetSharedStorage.shared.load()
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let targetYear = month >= 7 ? year + 1 : year
        
        let examDate: Date
        if let timestamp = shared?.examTimestamp {
            examDate = Date(timeIntervalSince1970: timestamp)
        } else {
            var components = DateComponents()
            components.year = targetYear
            components.month = 6
            components.day = 19
            components.hour = 10
            components.minute = 15
            examDate = calendar.date(from: components) ?? now
        }
        
        let days = max(0, calendar.dateComponents([.day], from: now, to: examDate).day ?? 0)
        
        if let shared = shared {
            return YKSWidgetEntry(
                date: now,
                daysRemaining: days,
                overallPercentage: shared.overallPercentage,
                completedCount: shared.completedCount,
                totalCount: shared.totalCount,
                targetYear: shared.targetYear,
                fieldTitle: shared.fieldTitle,
                themeColorHex: shared.themeColorHex
            )
        }
        
        return YKSWidgetEntry(
            date: now,
            daysRemaining: days,
            overallPercentage: 0,
            completedCount: 0,
            totalCount: 100,
            targetYear: targetYear,
            fieldTitle: "Sayısal",
            themeColorHex: "3B82F6"
        )
    }
}

// MARK: - Widget Arayüzü (SwiftUI View)
struct HedefYKSWidgetEntryView : View {
    var entry: YKSWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidgetView
            default:
                mediumWidgetView
            }
        }
        .widgetContainerBackground()
    }
    
    // 1. KÜÇÜK WIDGET (2x2)
    var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("YKS \(String(entry.targetYear))")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(entry.themeColor.opacity(0.15))
                    .foregroundColor(entry.themeColor)
                    .cornerRadius(6)
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(entry.daysRemaining)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(entry.themeColor)
                Text("Gün Kaldı")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(entry.completedCount)/\(entry.totalCount) Konu Bitti")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .padding(14)
    }
    
    // 2. ORTA WIDGET (4x2)
    var mediumWidgetView: some View {
        HStack(spacing: 16) {
            // Sol Taraf (Kalan Gün)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("YKS \(String(entry.targetYear))")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(entry.themeColor.opacity(0.15))
                        .foregroundColor(entry.themeColor)
                        .cornerRadius(6)
                    Spacer()
                }
                
                Text("\(entry.daysRemaining)")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(entry.themeColor)
                
                Text("Gün Kaldı")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Sağ Taraf (Alan & Durum)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Hedef: \(entry.fieldTitle)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Text("Genel İlerleme")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("%\(entry.overallPercentage)")
                        .font(.subheadline)
                        .fontWeight(.black)
                        .foregroundColor(entry.themeColor)
                }
                
                ProgressView(value: Double(entry.overallPercentage), total: 100)
                    .tint(entry.themeColor)
                
                Text("\(entry.completedCount)/\(entry.totalCount) Konu Bitti")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
    }
}

// MARK: - Widget Tanımlaması
struct HedefYKSWidget: Widget {
    let kind: String = "HedefYKSWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: YKSWidgetProvider()) { entry in
            HedefYKSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("YKS Geri Sayım")
        .description("YKS sınavına kalan günü ve çalışma ilerlemenizi takip edin.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - iOS 17+ Widget Container Background Support
extension View {
    @ViewBuilder
    func widgetContainerBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                Color(uiColor: .systemBackground)
            }
        } else {
            self.background(Color(uiColor: .systemBackground))
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 59, 130, 246)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
