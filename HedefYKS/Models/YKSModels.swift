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
            YKSCourse(id: "tyt-turkce", title: "TYT Türkçe", icon: "text.quote", section: "TYT", topics: [
                "Sözcükte Anlam ve Söz Yorumu", "Cümlede Anlam ve Cümle Yorumu", "Paragrafta Anlatım Teknikleri",
                "Paragrafta Yapı ve Ana Düşünce", "Ses Bilgisi", "Yazım Kuralları", "Noktalama İşaretleri",
                "Sözcük Türleri (İsim, Sıfat, Zamir, Zarf, Edat, Bağlaç, Ünlem)", "Fiiller, Fiilimsi ve Fiilde Çatı",
                "Cümlenin Ögeleri", "Cümle Türleri", "Anlatım Bozukluğu"
            ].enumerated().map { YKSTopic(id: "tyt-turkce-\($0.offset)", title: $0.element, courseId: "tyt-turkce") }),
            
            YKSCourse(id: "tyt-matematik", title: "TYT Matematik", icon: "x.squareroot", section: "TYT", topics: [
                "Temel Kavramlar ve Sayı Kümeleri", "Sayı Basamakları", "Bölme ve Bölünebilme", "EBOB-EKOK", "Rasyonel Sayılar",
                "Basit Eşitsizlikler", "Mutlak Değer", "Üslü İfadeler", "Köklü İfadeler", "Çarpanlara Ayırma", "Oran-Orantı",
                "Denklem Çözme", "Sayı ve Kesir Problemleri", "Yaş Problemleri", "Hız ve Hareket Problemleri",
                "Yüzde, Kâr-Zarar ve Faiz Problemleri", "Karışım ve İşçi Problemleri", "Kümeler ve Mantık",
                "Fonksiyonlar", "Polinomlar", "Sayma, Permütasyon ve Kombinasyon", "Olasılık ve İstatistik"
            ].enumerated().map { YKSTopic(id: "tyt-mat-\($0.offset)", title: $0.element, courseId: "tyt-matematik") }),
            
            YKSCourse(id: "tyt-geometri", title: "TYT Geometri", icon: "triangle", section: "TYT", topics: [
                "Doğruda ve Üçgende Açılar", "Özel Üçgenler (Dik, İkizkenar, Eşkenar)", "Açıortay ve Kenarortay",
                "Üçgende Eşlik, Benzerlik ve Alan", "Çokgenler ve Dörtgenler", "Paralelkenar ve Eşkenar Dörtgen",
                "Dikdörtgen ve Kare", "Yamuk ve Deltoid", "Çember ve Daire", "Analitik Geometri", "Katı Cisimler (Prizma, Piramit, Küre)"
            ].enumerated().map { YKSTopic(id: "tyt-geo-\($0.offset)", title: $0.element, courseId: "tyt-geometri") }),
            
            YKSCourse(id: "tyt-fizik", title: "TYT Fizik", icon: "atom", section: "TYT", topics: [
                "Fizik Bilimine Giriş ve Ölçme", "Madde ve Özellikleri", "Hareket ve Kuvvet", "İş, Güç ve Enerji",
                "Isı, Sıcaklık ve Genleşme", "Basınç ve Kaldırma Kuvveti", "Elektrik ve Manyetizma", "Dalgalar", "Optik"
            ].enumerated().map { YKSTopic(id: "tyt-fiz-\($0.offset)", title: $0.element, courseId: "tyt-fizik") }),
            
            YKSCourse(id: "tyt-kimya", title: "TYT Kimya", icon: "testtube.2", section: "TYT", topics: [
                "Kimya Bilimi", "Atom ve Periyodik Sistem", "Kimyasal Türler Arası Etkileşimler", "Maddenin Hâlleri",
                "Doğa ve Kimya", "Kimyanın Temel Kanunları ve Hesaplamalar", "Karışımlar", "Asitler, Bazlar ve Tuzlar", "Kimya Her Yerde"
            ].enumerated().map { YKSTopic(id: "tyt-kim-\($0.offset)", title: $0.element, courseId: "tyt-kimya") }),
            
            YKSCourse(id: "tyt-biyoloji", title: "TYT Biyoloji", icon: "leaf", section: "TYT", topics: [
                "Canlıların Ortak Özellikleri", "Canlıların Temel Bileşenleri", "Hücre ve Organelleri",
                "Hücre Zarından Madde Geçişleri", "Canlıların Sınıflandırılması", "Hücre Bölünmeleri ve Üreme",
                "Kalıtım ve Biyolojik Çeşitlilik", "Ekosistem Ekolojisi ve Çevre Sorunları"
            ].enumerated().map { YKSTopic(id: "tyt-biy-\($0.offset)", title: $0.element, courseId: "tyt-biyoloji") }),
            
            YKSCourse(id: "tyt-tarih", title: "TYT Tarih", icon: "building.columns", section: "TYT", topics: [
                "Tarih ve Zaman", "İlk ve Orta Çağlarda Türk Dünyası", "İslam Medeniyetinin Doğuşu", "Türklerin İslamiyet'i Kabulü",
                "Yerleşme ve Devletleşme Sürecinde Selçuklu ve Osmanlı", "Beylikten Devlete Osmanlı Siyaseti", "Dünya Gücü Osmanlı (1453-1600)",
                "19. Yüzyıl Osmanlı Devleti ve Islahatlar", "20. Yüzyıl Başlarında Osmanlı ve 1. Dünya Savaşı", "Milli Mücadele ve Kurtuluş Savaşı", "Atatürkçülük ve İnkılaplar"
            ].enumerated().map { YKSTopic(id: "tyt-tar-\($0.offset)", title: $0.element, courseId: "tyt-tarih") }),
            
            YKSCourse(id: "tyt-cografya", title: "TYT Coğrafya", icon: "map", section: "TYT", topics: [
                "Doğa ve İnsan", "Dünya'nın Şekli ve Hareketleri", "Coğrafi Konum ve Harita Bilgisi", "İklim Bilgisi (Sıcaklık, Nem, Yağış)",
                "İç ve Dış Kuvvetler", "Türkiye'nin Yer Şekilleri ve İklimi", "Nüfus ve Yerleşme", "Coğrafi Bölgeler ve Ulaşım Yolları", "Doğal Afetler ve Çevre"
            ].enumerated().map { YKSTopic(id: "tyt-cog-\($0.offset)", title: $0.element, courseId: "tyt-cografya") }),
            
            YKSCourse(id: "tyt-felsefe", title: "TYT Felsefe & Din", icon: "brain.head.profile", section: "TYT", topics: [
                "Felsefenin Konusu ve Özellikleri", "Bilgi Felsefesi (Epistemoloji)", "Varlık Felsefesi (Ontoloji)", "Ahlak ve Sanat Felsefesi",
                "Din, Siyaset ve Bilim Felsefesi", "İnanç ve İbadet Esasları", "Hz. Muhammed (S.A.V.) ve Kur'an-ı Kerim", "İslam Düşüncesinde Yorumlar ve Ahlak"
            ].enumerated().map { YKSTopic(id: "tyt-fel-\($0.offset)", title: $0.element, courseId: "tyt-felsefe") })
        ]
    }
    
    // SAYISAL AYT
    private static func sayisalAYTCourses() -> [YKSCourse] {
        return [
            YKSCourse(id: "ayt-matematik", title: "AYT Matematik", icon: "x.squareroot", section: "AYT", topics: [
                "Polinomlar ve 2. Dereceden Denklemler", "2. Dereceden Eşitsizlikler ve Parabol", "Karmaşık Sayılar",
                "Trigonometri (Toplam-Fark, Yarım Açı, Denklemler)", "Logaritma ve Üstel Fonksiyonlar",
                "Diziler (Aritmetik ve Geometrik Dizi)", "Limit ve Süreklilik", "Türev ve Uygulamaları",
                "İntegral ve Alan Hesaplama", "Dönüşüm Geometrisi (Öteleme, Dönme, Simetri)", "Çemberin Analitik İncelenmesi"
            ].enumerated().map { YKSTopic(id: "ayt-mat-\($0.offset)", title: $0.element, courseId: "ayt-matematik") }),
            
            YKSCourse(id: "ayt-fizik", title: "AYT Fizik", icon: "atom", section: "AYT", topics: [
                "Vektörler, Kütle Merkezi ve Denge", "Basit Makineler", "Sabit İvmeli Hareket ve Atışlar",
                "İtme ve Çizgisel Momentum", "Düzgün Çembersel Hareket ve Açısal Momentum", "Kütle Çekimi ve Kepler Yasaları",
                "Basit Harmonik Hareket", "Su ve Ses Dalgalarında Kırınım, Girişim ve Doppler", "Elektrostatik, Elektriksel Potansiyel ve Sığaçlar",
                "Manyetizma, Elektromanyetik İndükleme ve Alternatif Akım", "Transformatörler ve Elektromanyetik Dalgalar",
                "Özel Görelilik (Rölativite)", "Kuantum Fiziği, Fotoelektrik Olayı ve Compton Saçılması", "Modern Fiziğin Teknolojideki Uygulamaları"
            ].enumerated().map { YKSTopic(id: "ayt-fiz-\($0.offset)", title: $0.element, courseId: "ayt-fizik") }),
            
            YKSCourse(id: "ayt-kimya", title: "AYT Kimya", icon: "testtube.2", section: "AYT", topics: [
                "Modern Atom Teorisi ve Periyodik Sistem", "Gazlar (İdeal Gaz Yasası, Kinetik Teori)", "Sıvı Çözeltiler ve Derişim Birimleri",
                "Kimyasal Tepkimelerde Enerji (Entalpi)", "Kimyasal Tepkimelerde Hız", "Kimyasal Denge ve Dengeye Etki Eden Faktörler",
                "Sulu Çözelti Dengeleri (Asit-Baz, Tampon, Titrasyon)", "Çözünürlük Dengesi (KÇÇ)", "Kimya ve Elektrik (Redoks, Piller, Elektroliz)",
                "Karbon Kimyasına Giriş (Hibritleşme, Molekül Geometrisi)", "Organik Kimya (Alkan, Alken, Alkin, Alkol, Eter, Aldehit, Keton, Karboksilik Asit, Ester)"
            ].enumerated().map { YKSTopic(id: "ayt-kim-\($0.offset)", title: $0.element, courseId: "ayt-kimya") }),
            
            YKSCourse(id: "ayt-biyoloji", title: "AYT Biyoloji", icon: "leaf", section: "AYT", topics: [
                "Sinir Sistemi ve Duyu Organları", "Endokrin Sistem (Hormonlar)", "Destek ve Hareket Sistemi",
                "Sindirim Sistemi", "Dolaşım ve Lenf Sistemi (Bağışıklık)", "Solunum Sistemi",
                "Üriner Sistem (Boşaltım)", "Üreme Sistemi ve Gelişme", "Komünite ve Popülasyon Ekolojisi",
                "Genden Proteine (DNA, RNA ve Protein Sentezi)", "Genetik Mühendisliği ve Biyoteknoloji",
                "Canlılarda Enerji Dönüşümleri (Fotosentez, Kemosentez, Solunum)", "Bitki Biyolojisi (Dokular, Organlar, Taşıma, Büyüme ve Üreme)"
            ].enumerated().map { YKSTopic(id: "ayt-biy-\($0.offset)", title: $0.element, courseId: "ayt-biyoloji") })
        ]
    }
    
    // EŞİT AĞIRLIK AYT
    private static func eaAYTCourses() -> [YKSCourse] {
        var courses = sayisalAYTCourses().filter { $0.id == "ayt-matematik" }
        courses.append(contentsOf: [
            YKSCourse(id: "ayt-edebiyat", title: "AYT Edebiyat", icon: "book.pages", section: "AYT", topics: [
                "Güzel Sanatlar, Edebiyat ve Metinlerin Sınıflandırılması", "Edebi Türler ve Söz Sanatları",
                "Şiir Bilgisi (Ölçü, Kafiye, Redif, Nazım Şekilleri)", "İslamiyet Öncesi ve Geçiş Dönemi Türk Edebiyatı",
                "Halk Edebiyatı (Anonim, Âşık, Tekke-Tasavvuf)", "Divan Edebiyatı (Nazım Biçimleri, Şairler, Nesir)",
                "Tanzimat Edebiyatı (1. ve 2. Dönem)", "Servet-i Fünun ve Fecr-i Âti Edebiyatı",
                "Milli Edebiyat Dönemi ve Beş Hececiler", "Cumhuriyet Dönemi Şiir (Garip, İkinci Yeni, Toplumcu)",
                "Cumhuriyet Dönemi Roman, Hikaye ve Tiyatro", "Batı Edebiyatı ve Edebi Akımlar"
            ].enumerated().map { YKSTopic(id: "ayt-edb-\($0.offset)", title: $0.element, courseId: "ayt-edebiyat") }),
            
            YKSCourse(id: "ayt-tarih1", title: "AYT Tarih-1", icon: "building.columns.fill", section: "AYT", topics: [
                "Tarih Bilimi ve İnsanlığın İlk Dönemleri", "İlk ve Orta Çağlarda Türk Dünyası",
                "İslam Medeniyetinin Doğuşu ve İlk Türk-İslam Devletleri", "Selçuklu ve Osmanlı Devletleşme Süreci",
                "Dünya Gücü Osmanlı (1453-1600)", "Değişim Çağında Osmanlı ve Avrupa (17-18. Yüzyıl)",
                "19. Yüzyıl Osmanlı Devleti, Islahatlar ve Dağılma", "20. Yüzyıl Başlarında Osmanlı ve 1. Dünya Savaşı",
                "Milli Mücadele (Hazırlık, Cepheler ve Antlaşmalar)", "Atatürkçülük, İnkılaplar ve Türk Dış Politikası"
            ].enumerated().map { YKSTopic(id: "ayt-tar1-\($0.offset)", title: $0.element, courseId: "ayt-tarih1") }),
            
            YKSCourse(id: "ayt-cog1", title: "AYT Coğrafya-1", icon: "globe.europe.africa.fill", section: "AYT", topics: [
                "Ekosistem, Biyoçeşitlilik ve Madde Döngüleri", "Şehirlerin Fonksiyonları ve Etki Alanları",
                "Türkiye'de Nüfus, Yerleşme ve Göç Politikaları", "Türkiye'nin Ekonomi Politikaları ve Tarım/Hayvancılık",
                "Türkiye'de Madenler, Enerji Kaynakları ve Sanayi", "Türkiye'de Ulaşım, Ticaret ve Turizm",
                "Kültür Bölgeleri ve Türk Kültürünün Yayılışı", "Küresel ve Bölgesel Örgütler", "Çevre Sorunları ve Küresel İklim Değişimi"
            ].enumerated().map { YKSTopic(id: "ayt-cog1-\($0.offset)", title: $0.element, courseId: "ayt-cog1") })
        ])
        return courses
    }
    
    // SÖZEL AYT
    private static func sozelAYTCourses() -> [YKSCourse] {
        var courses = eaAYTCourses().filter { $0.id != "ayt-matematik" }
        courses.append(contentsOf: [
            YKSCourse(id: "ayt-tarih2", title: "AYT Tarih-2", icon: "clock.arrow.circlepath", section: "AYT", topics: [
                "İnsanlığın İlk Dönemleri ve Medeniyetlerin Doğuşu", "Türklerde Devlet Teşkilatı, Toplum Yapısı ve Hukuk",
                "İslam Medeniyeti ve Türk-İslam Devletleri Kültür/Medeniyeti", "Osmanlı Devlet Anlayışı, Askeri Yapı ve Toprak Düzeni",
                "20. Yüzyıl Başlarında Dünya ve 1. / 2. Dünya Savaşı", "Soğuk Savaş Dönemi (Türkiye ve Dünya)",
                "Yumuşama (Detant) Dönemi ve Çatışma Alanları", "Küreselleşen Dünya (1990 Sonrası Türkiye ve Türk Dünyası)"
            ].enumerated().map { YKSTopic(id: "ayt-tar2-\($0.offset)", title: $0.element, courseId: "ayt-tarih2") }),
            
            YKSCourse(id: "ayt-cog2", title: "AYT Coğrafya-2", icon: "map.circle.fill", section: "AYT", topics: [
                "Ekosistemlerin İşleyişi, Biyoçeşitlilik ve Madde Döngüleri", "Doğadaki Ekstrem Olaylar ve Geleceğin Şehirleri",
                "Türkiye'nin Nüfus Politikaları ve Şehirleşme", "Türkiye'de Bölgesel Kalkınma Projeleri (GAP, DAP, ZBK, DOKAP)",
                "Türkiye'de Sektörel Ekonomik Analiz (Tarım, Hayvancılık, Sanayi)", "Türkiye ve Dünya'da Ulaşım, Ticaret ve Turizm",
                "Kültür Bölgelerinin Oluşumu ve Türk Kültür Alanları", "Küresel İklim Değişimi, Çevre Sorunları ve Sürdürülebilirlik",
                "Uluslararası Örgütler ve Sıcak Çatışma Bölgeleri"
            ].enumerated().map { YKSTopic(id: "ayt-cog2-\($0.offset)", title: $0.element, courseId: "ayt-cog2") }),
            
            YKSCourse(id: "ayt-felsefe-grubu", title: "Felsefe Grubu", icon: "person.and.background.dotted", section: "AYT", topics: [
                "Psikoloji Bilimini Tanıyalım", "Psikolojinin Temel Süreçleri", "Öğrenme, Bellek ve Düşünme", "Ruh Sağlığının Temelleri",
                "Sosyolojiye Giriş", "Birey ve Toplum", "Toplumsal Yapı", "Toplumsal Değişme ve Gelişme", "Toplum ve Kültür", "Toplumsal Kurumlar",
                "Mantığa Giriş", "Klasik Mantık", "Mantık ve Dil", "Sembolik Mantık",
                "MÖ 6. YY - MS 2. YY Felsefesi", "MS 2. YY - MS 15. YY Felsefesi", "15. YY - 17. YY Felsefesi", "18. YY - 19. YY Felsefesi", "20. YY Felsefesi"
            ].enumerated().map { YKSTopic(id: "ayt-fg-\($0.offset)", title: $0.element, courseId: "ayt-felsefe-grubu") })
        ])
        return courses
    }
    
    // DİL YDT
    private static func dilAYTCourses() -> [YKSCourse] {
        return [
            YKSCourse(id: "ydt-ingilizce", title: "YDT İngilizce", icon: "character.book.closed.fill", section: "YDT", topics: [
                "Vocabulary & Phrasal Verbs", "Grammar (Tenses, Modals, Passive, Conjunctions)", "Cloze Test",
                "Sentence Completion (Cümle Tamamlama)", "Reading Comprehension (Paragraf Okuma-Anlama)",
                "Dialogue Completion (Diyalog Tamamlama)", "Restatement (Yakın Anlamlı Cümle)",
                "Situation (Duruma Uygun Cümle)", "Paragraph Completion (Paragraf Tamamlama)",
                "Translation (İngilizce-Türkçe / Türkçe-İngilizce Çeviri)", "Irrelevant Sentence (Anlam Bütünlüğünü Bozan Cümle)"
            ].enumerated().map { YKSTopic(id: "ydt-ing-\($0.offset)", title: $0.element, courseId: "ydt-ingilizce") })
        ]
    }
}
