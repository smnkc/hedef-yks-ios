import SwiftUI

// MARK: - YKS Alan Seçenekleri
enum YKSField: String, CaseIterable, Codable, Identifiable {
    case sayisal = "sayisal"
    case ea = "ea"
    case sozel = "sozel"
    case dil = "dil"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .sayisal: return "Sayısal"
        case .ea: return "Eşit Ağırlık"
        case .sozel: return "Sözel"
        case .dil: return "YDT Dil"
        }
    }
    
    var icon: String {
        switch self {
        case .sayisal: return "x.squareroot"
        case .ea: return "scale.3d"
        case .sozel: return "book.fill"
        case .dil: return "globe.americas.fill"
        }
    }
    
    var description: String {
        switch self {
        case .sayisal: return "TYT + AYT Matematik ve Fen Bilimleri"
        case .ea: return "TYT + AYT Matematik, Edebiyat, Tarih-1, Coğrafya-1"
        case .sozel: return "TYT + AYT Edebiyat, Tarih-2, Coğrafya-2, Felsefe Grubu"
        case .dil: return "TYT + YDT Yabancı Dil Testi ve Kelime Çalışmaları"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .sayisal: return Color.blue
        case .ea: return Color.red
        case .sozel: return Color.purple
        case .dil: return Color.emerald
        }
    }
}

extension Color {
    static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)
}

// MARK: - Konu Durumu (3 Aşamalı Döngü)
enum TopicState: Int, Codable, CaseIterable {
    case notStarted = 0
    case inProgress = 1
    case completed = 2
    
    var label: String {
        switch self {
        case .notStarted: return "Başlamadı"
        case .inProgress: return "Çalışılıyor"
        case .completed: return "Tamamlandı"
        }
    }
    
    var iconName: String {
        switch self {
        case .notStarted: return "circle"
        case .inProgress: return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .orange
        case .completed: return .green
        }
    }
    
    var nextState: TopicState {
        switch self {
        case .notStarted: return .inProgress
        case .inProgress: return .completed
        case .completed: return .notStarted
        }
    }
}

// MARK: - Konu Modeli
struct YKSTopic: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    let courseId: String
}

// MARK: - Ders Modeli
struct YKSCourse: Identifiable, Codable {
    let id: String
    var title: String
    var icon: String
    var section: String // "TYT" veya "AYT" / "YDT"
    var topics: [YKSTopic]
}

// MARK: - Müfredat Sağlayıcısı
struct YKSDataBank {
    static func getCourses(for field: YKSField) -> [YKSCourse] {
        var result: [YKSCourse] = []
        
        // TYT Ortak Dersler
        result.append(contentsOf: tytCommonCourses())
        
        // Alana Özel TYT / AYT Dersleri
        switch field {
        case .sayisal:
            result.append(contentsOf: sayisalAYTCourses())
        case .ea:
            result.append(contentsOf: eaAYTCourses())
        case .sozel:
            result.append(contentsOf: sozelAYTCourses())
        case .dil:
            result.append(contentsOf: dilAYTCourses())
        }
        
        return result
    }
    
    // TYT Tüm Alanlarda Ortak
    private static func tytCommonCourses() -> [YKSCourse] {
        return [
            YKSCourse(id: "tyt-turkce", title: "Türkçe", icon: "text.quote", section: "TYT", topics: [
                "Sözcükte Anlam", "Söz Yorumu", "Deyim ve Atasözü", "Cümlede Anlam", "Paragrafta Anlatım Teknikleri",
                "Paragrafta Yapı", "Paragrafta Ana Düşünce", "Ses Bilgisi", "Yazım Kuralları", "Noktalama İşaretleri",
                "Sözcük Türleri", "Fiiller ve Fiilimsi", "Cümlenin Ögeleri", "Cümle Türleri", "Anlatım Bozukluğu"
            ].enumerated().map { YKSTopic(id: "tyt-turkce-\($0.offset)", title: $0.element, courseId: "tyt-turkce") }),
            
            YKSCourse(id: "tyt-matematik", title: "Matematik", icon: "x.squareroot", section: "TYT", topics: [
                "Temel Kavramlar", "Sayı Basamakları", "Bölme-Bölünebilme", "EBOB-EKOK", "Rasyonel Sayılar",
                "Basit Eşitsizlikler", "Mutlak Değer", "Üslü-Köklü Sayılar", "Çarpanlara Ayırma", "Oran-Orantı",
                "Denklem Çözme", "Sayı ve Kesir Problemleri", "Yaş ve Hız Problemleri", "Yüzde-Kâr-Zarar",
                "Kümeler ve Mantık", "Fonksiyonlar", "Polinomlar", "Olasılık ve İstatistik"
            ].enumerated().map { YKSTopic(id: "tyt-mat- \($0.offset)", title: $0.element, courseId: "tyt-matematik") }),
            
            YKSCourse(id: "tyt-geometri", title: "Geometri", icon: "triangle", section: "TYT", topics: [
                "Doğruda ve Üçgende Açılar", "Özel Üçgenler", "Açıortay ve Kenarortay", "Üçgende Alan ve Benzerlik",
                "Çokgenler ve Dörtgenler", "Paralelkenar ve Eşkenar Dörtgen", "Dikdörtgen ve Kare", "Yamuk",
                "Çember ve Daire", "Katı Cisimler", "Analitik Geometri"
            ].enumerated().map { YKSTopic(id: "tyt-geo-\($0.offset)", title: $0.element, courseId: "tyt-geometri") }),
            
            YKSCourse(id: "tyt-tarih", title: "Tarih", icon: "building.columns", section: "TYT", topics: [
                "Tarih ve Zaman", "İlk Türk Devletleri", "İslam Medeniyeti", "Osmanlı Siyaseti ve Kuruluş",
                "Dünya Gücü Osmanlı", "19. Yüzyıl Osmanlı", "1. Dünya Savaşı", "Milli Mücadele", "Atatürk İnkılapları"
            ].enumerated().map { YKSTopic(id: "tyt-tar-\($0.offset)", title: $0.element, courseId: "tyt-tarih") }),
            
            YKSCourse(id: "tyt-cografya", title: "Coğrafya", icon: "map", section: "TYT", topics: [
                "Doğa ve İnsan", "Dünya'nın Şekli ve Hareketleri", "Harita Bilgisi", "İklim Bilgisi",
                "İç ve Dış Kuvvetler", "Nüfus ve Yerleşme", "Türkiye'nin Yer Şekilleri", "Doğal Afetler"
            ].enumerated().map { YKSTopic(id: "tyt-cog-\($0.offset)", title: $0.element, courseId: "tyt-cografya") }),
            
            YKSCourse(id: "tyt-felsefe", title: "Felsefe & Din", icon: "brain.head.profile", section: "TYT", topics: [
                "Felsefenin Konusu", "Bilgi Felsefesi", "Varlık Felsefesi", "Ahlak ve Sanat Felsefesi",
                "İnanç ve İbadet", "Hz. Muhammed (S.A.V.)", "Vahiy ve Akıl", "İslam ve Bilim"
            ].enumerated().map { YKSTopic(id: "tyt-fel-\($0.offset)", title: $0.element, courseId: "tyt-felsefe") })
        ]
    }
    
    // SAYISAL AYT
    private static func sayisalAYTCourses() -> [YKSCourse] {
        return [
            YKSCourse(id: "ayt-matematik", title: "AYT Matematik", icon: "x.squareroot", section: "AYT", topics: [
                "Karmaşık Sayılar", "2. Dereceden Denklemler ve Eşitsizlikler", "Parabol", "Trigonometri",
                "Logaritma", "Diziler", "Limit ve Süreklilik", "Türev ve Uygulamaları", "İntegral ve Alan"
            ].enumerated().map { YKSTopic(id: "ayt-mat-\($0.offset)", title: $0.element, courseId: "ayt-matematik") }),
            
            YKSCourse(id: "ayt-fizik", title: "AYT Fizik", icon: "atom", section: "AYT", topics: [
                "Vektörler ve Tork", "Newton'un Hareket Yasaları", "Atışlar ve Momentum", "Elektrik Alan ve Potansiyel",
                "Manyetizma ve İndüksiyon", "Çembersel Hareket", "Basit Harmonik Hareket", "Dalga Mekaniği", "Modern Fizik"
            ].enumerated().map { YKSTopic(id: "ayt-fiz-\($0.offset)", title: $0.element, courseId: "ayt-fizik") }),
            
            YKSCourse(id: "ayt-kimya", title: "AYT Kimya", icon: "testtube.2", section: "AYT", topics: [
                "Modern Atom Teorisi", "Gazlar", "Sıvı Çözeltiler", "Kimyasal Tepkimelerde Enerji ve Hız",
                "Kimyasal Denge", "Asit-Baz ve Çözünürlük Dengesi", "Kimya ve Elektrik", "Organik Kimya"
            ].enumerated().map { YKSTopic(id: "ayt-kim-\($0.offset)", title: $0.element, courseId: "ayt-kimya") }),
            
            YKSCourse(id: "ayt-biyoloji", title: "AYT Biyoloji", icon: "leaf", section: "AYT", topics: [
                "İnsan Fizyolojisi (Sistemler)", "Komünite ve Popülasyon Ekolojisi", "Genden Proteine (DNA/RNA)",
                "Canlılarda Enerji Dönüşümleri (Fotosentez/Solunum)", "Bitki Biyolojisi"
            ].enumerated().map { YKSTopic(id: "ayt-biy-\($0.offset)", title: $0.element, courseId: "ayt-biyoloji") })
        ]
    }
    
    // EŞİT AĞIRLIK AYT
    private static func eaAYTCourses() -> [YKSCourse] {
        var courses = sayisalAYTCourses().filter { $0.id == "ayt-matematik" }
        courses.append(contentsOf: [
            YKSCourse(id: "ayt-edebiyat", title: "AYT Edebiyat", icon: "book.pages", section: "AYT", topics: [
                "Şiir Bilgisi ve Edebi Sanatlar", "İslamiyet Öncesi ve Geçiş Dönemi", "Halk Edebiyatı", "Divan Edebiyatı",
                "Tanzimat Edebiyatı", "Servet-i Fünun ve Fecr-i Ati", "Milli Edebiyat", "Cumhuriyet Dönemi Türk Edebiyatı"
            ].enumerated().map { YKSTopic(id: "ayt-edb-\($0.offset)", title: $0.element, courseId: "ayt-edebiyat") }),
            
            YKSCourse(id: "ayt-tarih1", title: "AYT Tarih-1", icon: "building.columns.fill", section: "AYT", topics: [
                "İlk Çağ Uygarlıkları", "Türk-İslam Devletleri", "Osmanlı Medeniyeti", "Kurtuluş Savaşı Antlaşmaları", "Atatürk İlkeleri"
            ].enumerated().map { YKSTopic(id: "ayt-tar1-\($0.offset)", title: $0.element, courseId: "ayt-tarih1") }),
            
            YKSCourse(id: "ayt-cog1", title: "AYT Coğrafya-1", icon: "globe.europe.africa.fill", section: "AYT", topics: [
                "Ekosistem ve Biyoçeşitlilik", "Türkiye'nin Ekonomi Politikaları", "Kültür Bölgeleri", "Uluslararası Örgütler"
            ].enumerated().map { YKSTopic(id: "ayt-cog1-\($0.offset)", title: $0.element, courseId: "ayt-cog1") })
        ])
        return courses
    }
    
    // SÖZEL AYT
    private static func sozelAYTCourses() -> [YKSCourse] {
        var courses = eaAYTCourses().filter { $0.id != "ayt-matematik" }
        courses.append(contentsOf: [
            YKSCourse(id: "ayt-tarih2", title: "AYT Tarih-2", icon: "clock.arrow.circlepath", section: "AYT", topics: [
                "İnsanlığın Hafızası Tarih", "Devrimler Çağında Osmanlı", "20. Yüzyıl Başlarında Dünya", "Soğuk Savaş Dönemi"
            ].enumerated().map { YKSTopic(id: "ayt-tar2-\($0.offset)", title: $0.element, courseId: "ayt-tarih2") }),
            
            YKSCourse(id: "ayt-felsefe-grubu", title: "Felsefe Grubu", icon: "person.and.background.dotted", section: "AYT", topics: [
                "Psikoloji Bilimini Tanıyalım", "Sosyo-Kültürel Yapı", "Mantık ve Akıl Yürütme", "Klasik ve Sembolik Mantık"
            ].enumerated().map { YKSTopic(id: "ayt-fg-\($0.offset)", title: $0.element, courseId: "ayt-felsefe-grubu") })
        ])
        return courses
    }
    
    // DİL YDT
    private static func dilAYTCourses() -> [YKSCourse] {
        return [
            YKSCourse(id: "ydt-ingilizce", title: "YDT İngilizce", icon: "character.book.closed.fill", section: "YDT", topics: [
                "Grammar & Tenses", "Vocabulary (Phrasal Verbs)", "Cloze Test", "Sentence Completion",
                "Reading Comprehension (Paragraf)", "Dialogue Completion", "Translation (Çeviri)", "Irrelevant Sentence"
            ].enumerated().map { YKSTopic(id: "ydt-ing-\($0.offset)", title: $0.element, courseId: "ydt-ingilizce") })
        ]
    }
}
