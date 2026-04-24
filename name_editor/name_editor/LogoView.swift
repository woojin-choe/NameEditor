import SwiftUI

struct LogoView: View {
    var size: CGFloat = 100

    var body: some View {
        ZStack {
            // 명찰 몸체
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(Color.white)
                .frame(width: size, height: size * 1.1)
                .shadow(color: .black.opacity(0.12), radius: size * 0.08, y: size * 0.04)

            VStack(spacing: size * 0.06) {
                // 상단 클립 홀
                RoundedRectangle(cornerRadius: size * 0.04)
                    .fill(Color(hex: "FEE500"))
                    .frame(width: size * 0.36, height: size * 0.12)
                    .overlay(
                        Capsule()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: size * 0.12, height: size * 0.05)
                    )
                    .offset(y: -size * 0.05)

                // "NT" 이니셜
                Text("NT")
                    .font(.system(size: size * 0.34, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .offset(y: -size * 0.02)

                // 하단 이름줄 (명찰 라인 느낌)
                VStack(spacing: size * 0.05) {
                    Capsule()
                        .fill(Color(hex: "FEE500"))
                        .frame(width: size * 0.6, height: size * 0.06)
                    Capsule()
                        .fill(Color(hex: "E0E0E0"))
                        .frame(width: size * 0.44, height: size * 0.05)
                }
                .offset(y: -size * 0.04)
            }
        }
        .frame(width: size, height: size * 1.1)
    }
}

#Preview {
    ZStack {
        Color(hex: "FEE500").ignoresSafeArea()
        LogoView(size: 120)
    }
}
