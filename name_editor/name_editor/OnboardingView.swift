import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "nametag",
            title: "Nametag에 오신 걸\n환영합니다!",
            description: "이름을 원하는 형식으로\n빠르게 변환해 드립니다.",
            isLogo: true
        ),
        OnboardingPage(
            icon: "folder.badge.plus",
            title: "카테고리 만들기",
            description: "\"ADA/{이름}\" 처럼 형식을 만들면\n이름이 자동으로 채워집니다.\n\n카테고리 탭에서 추가해 보세요.",
            isLogo: false
        ),
        OnboardingPage(
            icon: "person.fill",
            title: "이름 변환하기",
            description: "이름을 입력하고 카테고리를 선택하면\n바로 결과가 나타납니다.\n\n복사 버튼으로 클립보드에 바로 저장!",
            isLogo: false
        ),
        OnboardingPage(
            icon: "clock.arrow.trianglehead.counterclockwise.rotate.90",
            title: "변환 기록",
            description: "최근 변환한 내역은\n자동으로 저장됩니다.\n\n언제든 다시 복사할 수 있어요.",
            isLogo: false
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 페이지 콘텐츠
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // 하단 컨트롤
            VStack(spacing: 20) {
                // 페이지 인디케이터
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color(hex: "FEE500") : Color(.systemGray4))
                            .frame(width: i == currentPage ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }

                // 버튼
                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation { currentPage += 1 }
                    } label: {
                        Text("다음")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "FEE500"))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)

                    Button("건너뛰기") {
                        onFinish()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                } else {
                    Button {
                        onFinish()
                    } label: {
                        Text("시작하기")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "FEE500"))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 48)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let isLogo: Bool
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if page.isLogo {
                LogoView(size: 100)
            } else {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FEE500").opacity(0.2))
                        .frame(width: 120, height: 120)
                    Image(systemName: page.icon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(Color(hex: "1A1A1A"))
                }
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.title2).fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)

                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
