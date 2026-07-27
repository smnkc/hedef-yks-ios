import SwiftUI

@main
struct HedefYKSApp: App {
    @StateObject private var dataManager = YKSDataManager()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if dataManager.hasCompletedOnboarding {
                    MainTabView()
                        .environmentObject(dataManager)
                } else {
                    AreaSelectionView(isFromSettings: false)
                        .environmentObject(dataManager)
                }
                
                if showSplash {
                    SplashScreenView(onFinished: {
                        showSplash = false
                    })
                    .environmentObject(dataManager)
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .environment(\.locale, Locale(identifier: "tr_TR"))
        }
    }
}
