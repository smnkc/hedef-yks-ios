import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    @Binding var selectedTab: Int
    @State private var selectedDashboardSection: String = "Tümü"
    
    private var availableSections: [String] {
        dataManager.currentField == .dil ? ["Tümü", "TYT", "YDT"] : ["Tümü", "TYT", "AYT"]
    }
    
    private var dashboardCourses: [YKSCourse] {
        if selectedDashboardSection == "Tümü" {
            return dataManager.courses
        } else {
            return dataManager.courses.filter { $0.section == selectedDashboardSection }
        }
    }
    
    private var sectionFilterParam: String? {
        selectedDashboardSection == "Tümü" ? nil : selectedDashboardSection
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - 1. HERO CARD (Geri Sayım & İlerleme)
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hedef: \(dataManager.currentField.title)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.white.opacity(0.2)))
                                
                                Text(verbatim: "YKS \(dataManager.targetExamYear) İlerlemen")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Sınav Geri Sayım Rozeti
                            VStack {
                                Text("\(dataManager.daysRemaining)")
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Gün Kaldı")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.2)))
                        }
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        // İlerleme Barı ve Yüzde
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Genel Tamamlanma")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                                Text("%\(Int(dataManager.overallPercentage))")
                                    .font(.title3)
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.25))
                                        .frame(height: 12)
                                    
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: geo.size.width * CGFloat(dataManager.overallPercentage / 100.0), height: 12)
                                        .animation(.spring(), value: dataManager.overallPercentage)
                                }
                            }
                            .frame(height: 12)
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
                    
                    // MARK: - 2. DURUM ÖZETİ ROZETLERİ (Seçili Sınav Türüne Göre)
                    HStack(spacing: 12) {
                        StatBadgeView(count: dataManager.notStartedTopicsCount(for: sectionFilterParam), label: "Başlamadı", color: .gray)
                        StatBadgeView(count: dataManager.inProgressTopicsCount(for: sectionFilterParam), label: "Çalışılıyor", color: .orange)
                        StatBadgeView(count: dataManager.completedTopicsCount(for: sectionFilterParam), label: "Tamamlandı", color: .green)
                    }
                    
                    // MARK: - 3. DERS BAZLI İLERLEME KARTLARI (Tümü / TYT / AYT Seçmeli)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Ders İlerlemeleri")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Picker("Sınav Türü", selection: $selectedDashboardSection) {
                                ForEach(availableSections, id: \.self) { section in
                                    Text(section).tag(section)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 180)
                        }
                        .padding(.horizontal, 4)
                        
                        ForEach(dashboardCourses) { course in
                            Button(action: {
                                dataManager.selectedCourseIdToExpand = course.id
                                selectedTab = 1 // Konu takip sekmesine geç
                            }) {
                                HStack(spacing: 14) {
                                    Image(systemName: course.icon)
                                        .font(.title3)
                                        .foregroundColor(dataManager.themeColor)
                                        .frame(width: 44, height: 44)
                                        .background(dataManager.themeColor.opacity(0.12))
                                        .cornerRadius(12)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(course.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                let completedCount = course.topics.filter { dataManager.getState(for: $0.id) == .completed }.count
                                                let totalCount = course.topics.count
                                                Text("\(completedCount)/\(totalCount) Bitti")
                                                    .font(.caption2)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(completedCount > 0 ? dataManager.themeColor : .secondary)
                                            }
                                            Spacer()
                                            Text("%\(Int(dataManager.coursePercentage(course)))")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(dataManager.themeColor)
                                        }
                                        
                                        ProgressView(value: dataManager.coursePercentage(course), total: 100)
                                            .tint(dataManager.themeColor)
                                    }
                                }
                                .padding(16)
                                .background(Color(uiColor: .systemGray6))
                                .cornerRadius(18)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("Hedef YKS")
            .onAppear {
                if !availableSections.contains(selectedDashboardSection) {
                    selectedDashboardSection = availableSections.first ?? "Tümü"
                }
            }
        }
    }
}

// MARK: - Stat Badge View Component
struct StatBadgeView: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(16)
    }
}
