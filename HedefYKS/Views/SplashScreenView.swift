import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.75
    @State private var opacity: Double = 0.0
    
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Uygulama İkon Rozeti
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [dataManager.themeColor, dataManager.themeColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 124, height: 124)
                        .shadow(color: dataManager.themeColor.opacity(0.35), radius: 24, x: 0, y: 12)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                VStack(spacing: 8) {
                    Text("Hedef YKS")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(verbatim: "YKS \(dataManager.targetExamYear) Hedefine Adım Adım")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                .opacity(opacity)
                .offset(y: isAnimating ? 0 : 15)
                
                Spacer()
                
                // Yükleniyor Göstergesi
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: dataManager.themeColor))
                    .scaleEffect(1.2)
                    .opacity(opacity)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                self.scale = 1.0
                self.opacity = 1.0
                self.isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.35)) {
                    onFinished()
                }
            }
        }
    }
}
