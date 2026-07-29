import SwiftUI

// MARK: - Başarım Rozeti Modeli
struct BadgeItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let category: BadgeCategory
    let isUnlocked: Bool
    let currentProgress: Int
    let totalProgress: Int
    let badgeColor: Color
    
    var percentage: Double {
        guard totalProgress > 0 else { return 0 }
        return min(1.0, Double(currentProgress) / Double(totalProgress))
    }
}

enum BadgeCategory: String, CaseIterable, Identifiable {
    case all = "Tümü"
    case milestones = "Genel"
    case tyt = "TYT"
    case ayt = "AYT / YDT"
    
    var id: String { rawValue }
}

struct AchievementsView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    @State private var selectedCategory: BadgeCategory = .all
    
    private var allBadges: [BadgeItem] {
        dataManager.computeAllBadges()
    }
    
    private var filteredBadges: [BadgeItem] {
        switch selectedCategory {
        case .all:
            return allBadges
        case .milestones:
            return allBadges.filter { $0.category == .milestones }
        case .tyt:
            return allBadges.filter { $0.category == .tyt }
        case .ayt:
            return allBadges.filter { $0.category == .ayt }
        }
    }
    
    private var unlockedCount: Int {
        allBadges.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - HERO CARD (Başarım Özeti)
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ROZETLER VE BAŞARIMLAR")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.white.opacity(0.2)))
                                
                                Text("Başarım Yolculuğun")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // İkon Rozeti
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 54, height: 54)
                                
                                Image(systemName: "trophy.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        // Rozet Kazanma Oranı
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(unlockedCount) / \(allBadges.count) Rozet Kazanıldı")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(unlockedCount == allBadges.count ? "Tebrikler! Tüm rozetleri topladın 🎉" : "Konuları tamamlayarak rozetleri aç!")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            
                            Spacer()
                            
                            Text("%\(allBadges.isEmpty ? 0 : Int((Double(unlockedCount) / Double(allBadges.count)) * 100))")
                                .font(.title)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [dataManager.themeColor, dataManager.themeColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(24)
                    .shadow(color: dataManager.themeColor.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    // MARK: - KATEGORİ PİCKER
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(BadgeCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // MARK: - ROZETLER GRID LİSTESİ
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        ForEach(filteredBadges) { badge in
                            BadgeCardView(badge: badge)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("Başarımlar")
        }
    }
}

// MARK: - Rozet Kart Bileşeni
struct BadgeCardView: View {
    let badge: BadgeItem
    
    var body: some View {
        VStack(spacing: 12) {
            // Rozet İkon Kutusu
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? badge.badgeColor.opacity(0.15) : Color(uiColor: .systemGray5))
                    .frame(width: 64, height: 64)
                
                Image(systemName: badge.iconName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(badge.isUnlocked ? badge.badgeColor : .gray)
                
                if !badge.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color.gray))
                        .offset(x: 22, y: 22)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                        .background(Circle().fill(Color.white))
                        .offset(x: 22, y: 22)
                }
            }
            .padding(.top, 4)
            
            // Başlık & Açıklama
            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(badge.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(badge.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28)
            }
            
            // İlerleme Durumu / Çubuğu
            if badge.isUnlocked {
                Text("Kazanıldı!")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badge.badgeColor.opacity(0.15))
                    .foregroundColor(badge.badgeColor)
                    .cornerRadius(8)
            } else {
                VStack(spacing: 4) {
                    ProgressView(value: badge.percentage)
                        .tint(badge.badgeColor)
                    
                    Text("\(badge.currentProgress)/\(badge.totalProgress)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(badge.isUnlocked ? 0.06 : 0.02), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(badge.isUnlocked ? badge.badgeColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
    }
}
