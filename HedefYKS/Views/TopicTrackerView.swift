import SwiftUI

enum TopicFilterOption: String, CaseIterable, Identifiable {
    case all = "Tümü"
    case notStarted = "Başlamadı"
    case inProgress = "Çalışılıyor"
    case completed = "Bitti"
    
    var id: String { rawValue }
}

struct TopicTrackerView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    
    @State private var selectedSection: String = "Tümü"
    @State private var searchText = ""
    @State private var selectedFilter: TopicFilterOption = .all
    @State private var expandedCourses: Set<String> = []
    
    private var availableSections: [String] {
        dataManager.currentField == .dil ? ["Tümü", "TYT", "YDT"] : ["Tümü", "TYT", "AYT"]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Üst Filtre Barları
                VStack(spacing: 8) {
                    // Sınav Türü Sekmesi (Tümü / TYT / AYT)
                    Picker("Sınav Türü", selection: $selectedSection) {
                        ForEach(availableSections, id: \.self) { section in
                            Text(section).tag(section)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Durum Filtresi (Tümü, Başlamadı, Çalışılıyor, Bitti)
                    Picker("Filtre", selection: $selectedFilter) {
                        ForEach(TopicFilterOption.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(uiColor: .systemBackground))
                
                Divider()
                
                // 2. PRO Kart Yapısında Konu ve Ders Listesi
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if filteredCourses.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("Bu filtreye uygun ders veya konu bulunamadı.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 40)
                        } else {
                            ForEach(filteredCourses) { course in
                                ProCourseCardView(
                                    course: course,
                                    selectedFilter: selectedFilter,
                                    isExpanded: expandedCourses.contains(course.id) || !searchText.isEmpty,
                                    topics: filteredTopics(for: course),
                                    showSectionBadge: selectedSection == "Tümü",
                                    onToggleExpand: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            if expandedCourses.contains(course.id) {
                                                expandedCourses.remove(course.id)
                                            } else {
                                                expandedCourses.insert(course.id)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .searchable(text: $searchText, prompt: "Derslerde veya konularda ara...")
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationTitle("Konu Takibi")
            .onAppear {
                if !availableSections.contains(selectedSection) {
                    selectedSection = availableSections.first ?? "Tümü"
                }
                if let targetId = dataManager.selectedCourseIdToExpand {
                    expandedCourses.removeAll()
                    expandedCourses.insert(targetId)
                    if let course = dataManager.courses.first(where: { $0.id == targetId }) {
                        selectedSection = course.section
                    }
                    dataManager.selectedCourseIdToExpand = nil
                }
            }
        }
    }
    
    // MARK: - Filtrelenmiş Dersler (Seçili filtreye göre konusu olmayan dersler gizlenir)
    private var filteredCourses: [YKSCourse] {
        dataManager.courses.filter { course in
            let matchesSection = (selectedSection == "Tümü" || course.section == selectedSection)
            if !matchesSection { return false }
            
            // Konu filtresi ve arama filtresine uyan en az 1 konu var mı?
            let matchingTopics = filteredTopics(for: course)
            return !matchingTopics.isEmpty
        }
    }
    
    // MARK: - Filtrelenmiş Konular
    private func filteredTopics(for course: YKSCourse) -> [YKSTopic] {
        course.topics.filter { topic in
            let matchesSearch = searchText.isEmpty || topic.title.localizedCaseInsensitiveContains(searchText) || course.title.localizedCaseInsensitiveContains(searchText)
            let state = dataManager.getState(for: topic.id)
            let matchesFilter: Bool
            switch selectedFilter {
            case .all: matchesFilter = true
            case .notStarted: matchesFilter = (state == .notStarted)
            case .inProgress: matchesFilter = (state == .inProgress)
            case .completed: matchesFilter = (state == .completed)
            }
            return matchesSearch && matchesFilter
        }
    }
}

// MARK: - PRO Ders Kartı Bileşeni
struct ProCourseCardView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    let course: YKSCourse
    let selectedFilter: TopicFilterOption
    let isExpanded: Bool
    let topics: [YKSTopic]
    let showSectionBadge: Bool
    let onToggleExpand: () -> Void
    
    private var subtitleText: String {
        let totalCount = course.topics.count
        let completedCount = course.topics.filter { dataManager.getState(for: $0.id) == .completed }.count
        let inProgressCount = course.topics.filter { dataManager.getState(for: $0.id) == .inProgress }.count
        let notStartedCount = course.topics.filter { dataManager.getState(for: $0.id) == .notStarted }.count
        
        switch selectedFilter {
        case .all:
            return "\(completedCount)/\(totalCount) Bitti"
        case .notStarted:
            return "\(notStartedCount) Konu Başlamadı"
        case .inProgress:
            return "\(inProgressCount) Konu Çalışılıyor"
        case .completed:
            return "\(completedCount)/\(totalCount) Bitti"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // DERS HEADER KARTI
            Button(action: onToggleExpand) {
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        // Sol İkon Kutusu
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(dataManager.themeColor.opacity(0.12))
                                .frame(width: 46, height: 46)
                            
                            Image(systemName: course.icon)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(dataManager.themeColor)
                        }
                        
                        // Ders Başlığı ve Etiket
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(course.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if showSectionBadge {
                                    Text(course.section)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(dataManager.themeColor.opacity(0.15))
                                        .foregroundColor(dataManager.themeColor)
                                        .cornerRadius(6)
                                }
                            }
                            
                            Text(subtitleText)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedFilter == .completed ? dataManager.themeColor : .secondary)
                        }
                        
                        Spacer()
                        
                        // Yüzde Rozeti
                        Text("%\(Int(dataManager.coursePercentage(course)))")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(dataManager.themeColor)
                        
                        // Ok İkonu
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                    
                    // İlerleme Çubuğu
                    ProgressView(value: dataManager.coursePercentage(course), total: 100)
                        .tint(dataManager.themeColor)
                }
                .padding(16)
                .background(Color(uiColor: .systemGray6))
            }
            .buttonStyle(PlainButtonStyle())
            
            // AÇILIR KONU LİSTESİ
            if isExpanded {
                VStack(spacing: 8) {
                    if topics.isEmpty {
                        Text("Bu filtreye uygun konu bulunamadı.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 16)
                    } else {
                        ForEach(topics) { topic in
                            ProTopicRowView(topic: topic)
                        }
                    }
                }
                .padding(12)
                .background(Color(uiColor: .systemGray6).opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
            }
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

// MARK: - PRO Konu Satırı Bileşeni
struct ProTopicRowView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    let topic: YKSTopic
    
    var body: some View {
        let state = dataManager.getState(for: topic.id)
        
        Button(action: {
            dataManager.toggleTopicState(for: topic.id)
        }) {
            HStack(spacing: 12) {
                // Durum İkonu
                Image(systemName: state.iconName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(state.color)
                
                // Konu İsmi
                Text(topic.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(state == .completed ? .secondary : .primary)
                    .strikethrough(state == .completed, color: .secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Durum Rozeti
                Text(state.label)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(state.color.opacity(0.15))
                    .foregroundColor(state.color)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
