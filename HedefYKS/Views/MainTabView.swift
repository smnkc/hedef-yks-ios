import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Özet", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            TopicTrackerView()
                .tabItem {
                    Label("Konular", systemImage: "checkmark.square.fill")
                }
                .tag(1)
            
            AchievementsView()
                .tabItem {
                    Label("Başarımlar", systemImage: "trophy.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(dataManager.themeColor)
    }
}
