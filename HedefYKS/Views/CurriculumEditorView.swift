import SwiftUI

struct CurriculumEditorView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    
    @State private var expandedCourses: Set<String> = []
    
    // Ders Silme Onay Popup
    @State private var courseToDelete: YKSCourse? = nil
    @State private var showDeleteCourseAlert = false
    
    // Konu Silme Onay Popup
    @State private var topicToDelete: (topic: YKSTopic, courseId: String)? = nil
    @State private var showDeleteTopicAlert = false
    
    // Ders Ekleme
    @State private var showAddCourseAlert = false
    @State private var newCourseTitle = ""
    
    // Konu Ekleme
    @State private var showAddTopicAlert = false
    @State private var targetCourseIdForNewTopic: String? = nil
    @State private var newTopicTitle = ""
    
    // Konu Düzenleme
    @State private var showEditTopicAlert = false
    @State private var editingTopicId: String? = nil
    @State private var editingTopicCourseId: String? = nil
    @State private var editingTopicTitle = ""
    
    // Müfredat Sıfırlama
    @State private var showResetCurriculumAlert = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // MARK: - DERSLER VE KONULAR (PRO Akordeon Kartları)
                ForEach(dataManager.courses) { course in
                    let isExpanded = expandedCourses.contains(course.id)
                    
                    VStack(spacing: 0) {
                        // DERS HEADER KARTI
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    if expandedCourses.contains(course.id) {
                                        expandedCourses.remove(course.id)
                                    } else {
                                        expandedCourses.insert(course.id)
                                    }
                                }
                            }) {
                                HStack(spacing: 14) {
                                    // Sol İkon Kutusu
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(dataManager.themeColor.opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: course.icon)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(dataManager.themeColor)
                                    }
                                    
                                    // Ders Başlığı ve Etiket
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text(course.title)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                            
                                            Text(course.section)
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(dataManager.themeColor.opacity(0.15))
                                                .foregroundColor(dataManager.themeColor)
                                                .cornerRadius(6)
                                        }
                                        
                                        Text("\(course.topics.count) Konu")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Ok İkonu
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Ders Silme Butonu (Çöp Kutusu)
                            Button(action: {
                                courseToDelete = course
                                showDeleteCourseAlert = true
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(10)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(16)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(20)
                        
                        // AÇILIR KONU DÜZENLEME LİSTESİ
                        if isExpanded {
                            VStack(spacing: 8) {
                                ForEach(course.topics) { topic in
                                    HStack(spacing: 12) {
                                        Text(topic.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        // Konu Düzenle Butonu (Kalem)
                                        Button(action: {
                                            editingTopicId = topic.id
                                            editingTopicCourseId = course.id
                                            editingTopicTitle = topic.title
                                            showEditTopicAlert = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(dataManager.themeColor)
                                                .padding(8)
                                                .background(dataManager.themeColor.opacity(0.12))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        // Konu Sil Butonu (Çöp Kutusu)
                                        Button(action: {
                                            topicToDelete = (topic, course.id)
                                            showDeleteTopicAlert = true
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.red)
                                                .padding(8)
                                                .background(Color.red.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                }
                                
                                // "+ Yeni Konu Ekle" Butonu
                                Button(action: {
                                    targetCourseIdForNewTopic = course.id
                                    newTopicTitle = ""
                                    showAddTopicAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Yeni Konu Ekle")
                                            .fontWeight(.semibold)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(dataManager.themeColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(dataManager.themeColor.opacity(0.12))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.top, 4)
                            }
                            .padding(12)
                            .background(Color(uiColor: .systemGray6).opacity(0.4))
                            .cornerRadius(20)
                            .padding(.top, 4)
                        }
                    }
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                }
                
                // MARK: - YENİ DERS EKLE BUTONU
                Button(action: {
                    newCourseTitle = ""
                    showAddCourseAlert = true
                }) {
                    HStack {
                        Image(systemName: "plus.app.fill")
                            .font(.title3)
                        Text("Yeni Ders Ekle")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(dataManager.themeColor)
                    .cornerRadius(20)
                    .shadow(color: dataManager.themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 8)
                
                // MARK: - MÜFREDATI VARSAYILANA SIFIRLA
                Button(role: .destructive, action: {
                    showResetCurriculumAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Müfredatı Varsayılana Sıfırla")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 12)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .navigationTitle("Müfredat Düzenleyici")
        
        // MARK: - ALERTS
        // 1. DERS SİLME ONAY POPUP
        .alert("Dersi Silmek İstediğinize Emin Misiniz?", isPresented: $showDeleteCourseAlert) {
            Button("İptal", role: .cancel) { }
            Button("Evet, Dersi Sil", role: .destructive) {
                if let course = courseToDelete {
                    dataManager.deleteCourse(course.id)
                }
            }
        } message: {
            if let course = courseToDelete {
                Text("'\(course.title)' dersi ve altındaki tüm konular silinecektir. Bu işlem geri alınamaz.")
            } else {
                Text("Seçilen ders ve konuları silinecektir.")
            }
        }
        
        // 2. KONU SİLME ONAY POPUP
        .alert("Konu Silinsin mi?", isPresented: $showDeleteTopicAlert) {
            Button("İptal", role: .cancel) { }
            Button("Evet, Sil", role: .destructive) {
                if let item = topicToDelete {
                    dataManager.deleteTopic(item.topic.id, from: item.courseId)
                }
            }
        } message: {
            if let item = topicToDelete {
                Text("'\(item.topic.title)' konusu silinecektir.")
            } else {
                Text("Seçilen konu silinecektir.")
            }
        }
        
        // 3. YENİ KONU EKLEME ALERT
        .alert("Yeni Konu Ekle", isPresented: $showAddTopicAlert) {
            TextField("Konu Başlığı", text: $newTopicTitle)
            Button("İptal", role: .cancel) { }
            Button("Ekle") {
                if let courseId = targetCourseIdForNewTopic, !newTopicTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    dataManager.addTopic(to: courseId, title: newTopicTitle.trimmingCharacters(in: .whitespaces))
                }
            }
        } message: {
            Text("Derse eklenecek yeni konunun adını yazın.")
        }
        
        // 4. KONU ADI DÜZENLEME ALERT
        .alert("Konu Adını Düzenle", isPresented: $showEditTopicAlert) {
            TextField("Konu Başlığı", text: $editingTopicTitle)
            Button("İptal", role: .cancel) { }
            Button("Kaydet") {
                if let courseId = editingTopicCourseId, let topicId = editingTopicId, !editingTopicTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    dataManager.updateTopicTitle(topicId, in: courseId, newTitle: editingTopicTitle.trimmingCharacters(in: .whitespaces))
                }
            }
        }
        
        // 5. YENİ DERS EKLEME ALERT
        .alert("Yeni Ders Ekle", isPresented: $showAddCourseAlert) {
            TextField("Ders Adı (Örn: Geometri 2)", text: $newCourseTitle)
            Button("İptal", role: .cancel) { }
            Button("TYT Olarak Ekle") {
                if !newCourseTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    dataManager.addCourse(title: newCourseTitle.trimmingCharacters(in: .whitespaces), section: "TYT")
                }
            }
            Button("AYT Olarak Ekle") {
                if !newCourseTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    let sec = dataManager.currentField == .dil ? "YDT" : "AYT"
                    dataManager.addCourse(title: newCourseTitle.trimmingCharacters(in: .whitespaces), section: sec)
                }
            }
        }
        
        // 6. MÜFREDAT SIFIRLAMA ALERT
        .alert("Müfredat Sıfırlansın mı?", isPresented: $showResetCurriculumAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sıfırla", role: .destructive) {
                dataManager.resetCurriculumToDefault()
                expandedCourses.removeAll()
            }
        } message: {
            Text("Eklediğiniz özel ders ve konular silinerek orijinal ÖSYM müfredatına dönülecektir.")
        }
    }
}
