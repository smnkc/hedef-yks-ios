import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    @State private var showAreaPickerSheet = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // 1. Alan Değiştirme
                Section(header: Text("Hedef ve Alan Yapılandırması")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mevcut Alanın")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(dataManager.currentField.title)
                                .font(.headline)
                                .foregroundColor(dataManager.themeColor)
                        }
                        
                        Spacer()
                        
                        Button("Değiştir") {
                            showAreaPickerSheet = true
                        }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .buttonStyle(.borderedProminent)
                        .tint(dataManager.themeColor)
                    }
                    .padding(.vertical, 4)
                }
                
                // 2. Tema Rengi Özelleştirme
                Section(header: Text("Uygulama Tema Rengi")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(YKSDataManager.themePalette, id: \.name) { preset in
                                Button(action: {
                                    withAnimation {
                                        dataManager.customThemeColorName = preset.name
                                    }
                                }) {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(preset.color == .clear ? dataManager.currentField.themeColor : preset.color)
                                                .frame(width: 38, height: 38)
                                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            
                                            if (dataManager.customThemeColorName == preset.name) || (dataManager.customThemeColorName.isEmpty && preset.name == "Varsayılan") {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        
                                        Text(preset.name)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // 3. Müfredat Özelleştirme ve Düzenleyici
                Section(header: Text("Müfredat Yönetimi")) {
                    NavigationLink(destination: CurriculumEditorView().environmentObject(dataManager)) {
                        HStack {
                            Label("Ders ve Konuları Düzenle", systemImage: "pencil.and.outline")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // 4. YKS Sınav Tarihi Yapılandırması
                Section(header: Text("Sınav Tarihi")) {
                    DatePicker("YKS Sınav Tarihi", selection: Binding(
                        get: { dataManager.examDate },
                        set: { dataManager.examDate = $0 }
                    ), displayedComponents: [.date])
                }
                
                // 5. İlerleme Sıfırlama
                Section(header: Text("Veri Yönetimi")) {
                    Button(role: .destructive, action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Tüm İlerlemeyi Sıfırla")
                        }
                    }
                }
                
                // 6. Hakkında ve Sürüm & Geliştirici Notu
                Section(header: Text("Uygulama Hakkında"), footer: teacherNoteView) {
                    HStack {
                        Text("Uygulama Adı")
                        Spacer()
                        Text("Hedef YKS")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text("1.0.0 (Native iOS)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Çalışma Modu")
                        Spacer()
                        Label("Tam Çevrimdışı (Offline)", systemImage: "wifi.slash")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Ayarlar")
            .sheet(isPresented: $showAreaPickerSheet) {
                AreaSelectionView(isFromSettings: true)
                    .environmentObject(dataManager)
            }
            .alert("Tüm İlerleme Sıfırlansın mı?", isPresented: $showResetAlert) {
                Button("İptal", role: .cancel) { }
                Button("Evet, Sıfırla", role: .destructive) {
                    dataManager.resetAllProgress()
                }
            } message: {
                Text("Tüm ders ve konuların tamamlanma durumları silinecektir. Bu işlem geri alınamaz.")
            }
        }
    }
    
    // MARK: - Öğretmen Notu ve Instagram Bağlantısı
    private var teacherNoteView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 0) {
                Text("Bu uygulama öğretmen ")
                    .foregroundColor(.secondary)
                
                Link("Osman Akça", destination: URL(string: "https://www.instagram.com/smanakca")!)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(dataManager.themeColor)
                    .underline()
                
                Text(" tarafından")
                    .foregroundColor(.secondary)
            }
            Text("kullanımınıza ücretsiz sunulmuştur.")
                .foregroundColor(.secondary)
        }
        .font(.footnote)
        .padding(.top, 8)
    }
}
