import SwiftUI

struct CelebrationOverlayView: View {
    let badge: BadgeItem
    let onDismiss: () -> Void
    
    @State private var animateScale: CGFloat = 0.5
    @State private var animateOpacity: Double = 0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Arka Plan Karartma (Blur Effect)
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Tebrik Kartı
            VStack(spacing: 20) {
                // Işıltılı Arka Plan Dairesi & İkon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [badge.badgeColor.opacity(0.4), badge.badgeColor.opacity(0.0)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    Circle()
                        .fill(badge.badgeColor.opacity(0.2))
                        .frame(width: 96, height: 96)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(badge.badgeColor)
                        .shadow(color: badge.badgeColor.opacity(0.6), radius: 10, x: 0, y: 4)
                    
                    // Rozet Rozeti
                    Image(systemName: "star.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(6)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 4)
                        .offset(x: 32, y: -32)
                }
                .padding(.top, 10)
                
                // Başlıklar
                VStack(spacing: 8) {
                    Text("TEBRİKLER! 🎉")
                        .font(.caption)
                        .fontWeight(.black)
                        .tracking(2)
                        .foregroundColor(badge.badgeColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(badge.badgeColor.opacity(0.15)))
                    
                    Text("Yeni Başarım Kazanıldı!")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                    
                    Text(badge.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(badge.badgeColor)
                        .multilineTextAlignment(.center)
                    
                    Text(badge.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                // Buton
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Harika!")
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [badge.badgeColor, badge.badgeColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: badge.badgeColor.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 10)
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(badge.badgeColor.opacity(0.3), lineWidth: 2)
            )
            .padding(.horizontal, 32)
            .scaleEffect(animateScale)
            .opacity(animateOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                animateScale = 1.0
                animateOpacity = 1.0
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            // Başarım titreşim efekti
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.notificationOccurred(.success)
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            animateScale = 0.8
            animateOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}
