import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 30

    var body: some View {
        ZStack {
            Color(hex: "FEE500").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    LogoView(size: 110)

                    Text("Nametag")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.black)

                    Text("Smart name formatting")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.55))
                }

                Spacer()

                VStack(spacing: 14) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        authManager.handleSignIn(result: result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 54)
                    .cornerRadius(14)

                    Button {
                        authManager.continueAsGuest()
                    } label: {
                        Text("비로그인으로 계속")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.black.opacity(0.08))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 52)
            }
            .opacity(opacity)
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 1
                    offset = 0
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
