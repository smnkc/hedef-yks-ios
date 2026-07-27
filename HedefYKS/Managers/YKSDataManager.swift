import SwiftUI
import Combine
import WidgetKit

class YKSDataManager: ObservableObject {
    @AppStorage("selected_field") var selectedFieldRaw: String = YKSField.sayisal.rawValue {
        didSet {
            loadCurriculum()
        }
    }
    
    @AppStorage("has_completed_onboarding") var hasCompletedOnboarding: Bool = false
    
    // Tema Rengi Özelleştirme
    @AppStorage("custom_theme_color_name") var customThemeColorName: String = "" {
        didSet {
            syncWidget()
        }
    }
    
    static let themePalette: [(name: String, color: Color)] = [
        ("Varsayılan", Color.clear),
        ("Mavi", Color.blue),
        ("Kırmızı", Color.red),
        ("Mor", Color.purple),
        ("Yeşil", Color.emerald),
        ("Turuncu", Color.orange),
        ("Pembe", Color.pink),
        ("İndigo", Color.indigo),
        ("Turkuaz", Color.teal)
    ]
    
    var themeColor: Color {
        if let match = YKSDataManager.themePalette.first(where: { $0.name == customThemeColorName }), match.color != Color.clear {
            return match.color
        }
        return currentField.themeColor
    }
    
    var themeColorHex: String {
        let uiColor = UIColor(themeColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "%06X", rgb)
    }
    
    @Published var courses: [YKSCourse] = []
    @Published var topicProgress: [String: TopicState] = [:]
    @Published var selectedCourseIdToExpand: String? = nil
    
    // Dinamik YKS Hedef Yılı (Telefon tarihine göre her 1 Temmuz'da otomatik sonraki yıla geçer)
    var targetExamYear: Int {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        return month >= 7 ? year + 1 : year
    }
    
    static func defaultExamTimestamp() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let targetYear = month >= 7 ? year + 1 : year
        
        var components = DateComponents()
        components.year = targetYear
        components.month = 6
        components.day = 19
        components.hour = 10
        components.minute = 15
        return (calendar.date(from: components) ?? now).timeIntervalSince1970
    }
    
    // YKS Sınav Tarihi (Dinamik varsayılan)
    @AppStorage("custom_exam_timestamp") var examTimestamp: Double = YKSDataManager.defaultExamTimestamp()
    
    var examDate: Date {
        get {
            let savedDate = Date(timeIntervalSince1970: examTimestamp)
            // Eğer kaydedilen sınav tarihi geçmişte kaldıysa (örneğin 1 Temmuz sonrasına geçildiyse),
            // otomatik olarak yeni hedef yılın 19 Haziran tarihine güncelle!
            if savedDate < Date() {
                let defaultTimestamp = YKSDataManager.defaultExamTimestamp()
                return Date(timeIntervalSince1970: defaultTimestamp)
            }
            return savedDate
        }
        set {
            examTimestamp = newValue.timeIntervalSince1970
            objectWillChange.send()
        }
    }
    
    private let progressStorageKey = "hedef_yks_progress_data_v1"
    
    var currentField: YKSField {
        get { YKSField(rawValue: selectedFieldRaw) ?? .sayisal }
        set { selectedFieldRaw = newValue.rawValue }
    }
    
    init() {
        loadProgress()
        loadCurriculum()
        syncWidget()
    }
    
    func syncWidget() {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let targetYear = month >= 7 ? year + 1 : year
        let days = max(0, calendar.dateComponents([.day], from: now, to: examDate).day ?? 0)
        
        let completed = completedTopicsCount()
        let total = totalTopicsCount()
        let unstarted = max(0, total - completed)
        let percentage = Int(overallPercentage)
        
        let widgetData = SharedWidgetData(
            daysRemaining: days,
            overallPercentage: percentage,
            completedCount: completed,
            totalCount: total,
            unstartedCount: unstarted,
            targetYear: targetYear,
            fieldTitle: currentField.title,
            themeColorHex: themeColorHex
        )
        YKSWidgetSharedStorage.shared.save(data: widgetData)
    }
    
    private var curriculumStorageKey: String {
        "hedef_yks_custom_curriculum_v1_\(selectedFieldRaw)"
    }
    
    func loadCurriculum() {
        if let data = UserDefaults.standard.data(forKey: curriculumStorageKey),
           let decoded = try? JSONDecoder().decode([YKSCourse].self, from: data) {
            self.courses = decoded
        } else {
            self.courses = YKSDataBank.getCourses(for: currentField)
        }
    }
    
    func saveCurriculum() {
        if let encoded = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(encoded, forKey: curriculumStorageKey)
        }
        objectWillChange.send()
    }
    
    func resetCurriculumToDefault() {
        UserDefaults.standard.removeObject(forKey: curriculumStorageKey)
        loadCurriculum()
    }
    
    // MARK: - Konu Ekleme / Silme / Düzenleme
    func addTopic(to courseId: String, title: String) {
        guard let index = courses.firstIndex(where: { $0.id == courseId }) else { return }
        let newTopicId = "\(courseId)-custom-\(UUID().uuidString.prefix(6))"
        let newTopic = YKSTopic(id: newTopicId, title: title, courseId: courseId)
        courses[index].topics.append(newTopic)
        saveCurriculum()
    }
    
    func deleteTopic(_ topicId: String, from courseId: String) {
        guard let courseIndex = courses.firstIndex(where: { $0.id == courseId }) else { return }
        courses[courseIndex].topics.removeAll { $0.id == topicId }
        topicProgress.removeValue(forKey: topicId)
        saveProgress()
        saveCurriculum()
    }
    
    func updateTopicTitle(_ topicId: String, in courseId: String, newTitle: String) {
        guard let courseIndex = courses.firstIndex(where: { $0.id == courseId }),
              let topicIndex = courses[courseIndex].topics.firstIndex(where: { $0.id == topicId }) else { return }
        courses[courseIndex].topics[topicIndex].title = newTitle
        saveCurriculum()
    }
    
    // MARK: - Ders Ekleme / Silme
    func addCourse(title: String, section: String) {
        let newCourseId = "custom-course-\(UUID().uuidString.prefix(6))"
        let newCourse = YKSCourse(id: newCourseId, title: title, icon: "book.fill", section: section, topics: [])
        courses.append(newCourse)
        saveCurriculum()
    }
    
    func deleteCourse(_ courseId: String) {
        if let course = courses.first(where: { $0.id == courseId }) {
            for topic in course.topics {
                topicProgress.removeValue(forKey: topic.id)
            }
            saveProgress()
        }
        courses.removeAll { $0.id == courseId }
        saveCurriculum()
    }
    
    // MARK: - İlerleme Saklama ve Yükleme
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressStorageKey),
           let decoded = try? JSONDecoder().decode([String: TopicState].self, from: data) {
            self.topicProgress = decoded
        }
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(topicProgress) {
            UserDefaults.standard.set(encoded, forKey: progressStorageKey)
        }
        syncWidget()
    }
    
    // MARK: - Konu Durumu Değiştirme (Haptic Feedback)
    func toggleTopicState(for topicId: String) {
        let current = topicProgress[topicId] ?? .notStarted
        let next = current.nextState
        topicProgress[topicId] = next
        saveProgress()
        
        // Haptic Titreşim Geri Bildirimi
        let generator = UIImpactFeedbackGenerator(style: next == .completed ? .medium : .light)
        generator.impactOccurred()
    }
    
    func getState(for topicId: String) -> TopicState {
        return topicProgress[topicId] ?? .notStarted
    }
    
    // MARK: - İstatistik Hesaplamaları
    func totalTopicsCount(for section: String? = nil) -> Int {
        let filtered = section == nil ? courses : courses.filter { $0.section == section }
        return filtered.reduce(0) { $0 + $1.topics.count }
    }
    
    func completedTopicsCount(for section: String? = nil) -> Int {
        let filtered = section == nil ? courses : courses.filter { $0.section == section }
        var count = 0
        for course in filtered {
            for topic in course.topics {
                if getState(for: topic.id) == .completed {
                    count += 1
                }
            }
        }
        return count
    }
    
    func inProgressTopicsCount(for section: String? = nil) -> Int {
        let filtered = section == nil ? courses : courses.filter { $0.section == section }
        var count = 0
        for course in filtered {
            for topic in course.topics {
                if getState(for: topic.id) == .inProgress {
                    count += 1
                }
            }
        }
        return count
    }
    
    func notStartedTopicsCount(for section: String? = nil) -> Int {
        totalTopicsCount(for: section) - completedTopicsCount(for: section) - inProgressTopicsCount(for: section)
    }
    
    var overallPercentage: Double {
        let total = totalTopicsCount()
        guard total > 0 else { return 0 }
        return (Double(completedTopicsCount()) / Double(total)) * 100.0
    }
    
    func coursePercentage(_ course: YKSCourse) -> Double {
        guard !course.topics.isEmpty else { return 0 }
        let completed = course.topics.filter { getState(for: $0.id) == .completed }.count
        return (Double(completed) / Double(course.topics.count)) * 100.0
    }
    
    // Sınava Kalan Gün Hesabı
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: examDate)
        return max(0, components.day ?? 0)
    }
    
    func resetAllProgress() {
        topicProgress.removeAll()
        saveProgress()
        hasCompletedOnboarding = false
    }
}
