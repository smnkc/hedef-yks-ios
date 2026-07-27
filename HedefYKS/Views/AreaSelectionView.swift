import SwiftUI

struct AreaSelectionView: View {
    @EnvironmentObject var dataManager: YKSDataManager
    @Environment(\.dismiss) var dismiss
    var isFromSettings: Bool = false
    
    @State private var selected: YKSField = .sayisal
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("🎯 Hedefini Seç")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Hazırlandığın YKS alanını seçerek sana özel hazırlanmış konularla takibe başla.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 32)
            
            // Grid / Cards
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(YKSField.allCases) { field in
                        AreaCardView(field: field, isSelected: selected == field) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selected = field
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            
            // Devam Et Butonu
            Button(action: {
                dataManager.currentField = selected
                if isFromSettings {
                    dismiss()
                } else {
                    withAnimation {
                        dataManager.hasCompletedOnboarding = true
                    }
                }
            }) {
                HStack {
                    Text(isFromSettings ? "Alanı Güncelle" : "Hedefe Başla")
                        .font(.headline)
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(selected.themeColor)
                .cornerRadius(18)
                .shadow(color: selected.themeColor.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .onAppear {
            selected = dataManager.currentField
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Area Card Component
struct AreaCardView: View {
    let field: YKSField
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(field.themeColor.opacity(isSelected ? 1 : 0.12))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: field.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : field.themeColor)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(field.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(field.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Checkmark
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? field.themeColor : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(field.themeColor)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(uiColor: .systemGray6))
                    .shadow(color: isSelected ? field.themeColor.opacity(0.2) : Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? field.themeColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
