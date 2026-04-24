import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color(hex: "FEE500")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                LogoView(size: 120)

                Text("Nametag")
                    .font(.title).fontWeight(.bold)
                    .foregroundColor(.black)

                Text("Smart name formatting")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
