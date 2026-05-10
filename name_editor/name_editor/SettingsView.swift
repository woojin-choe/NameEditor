import SwiftUI

struct SettingsView: View {
    @Environment(AuthManager.self) private var authManager
    @EnvironmentObject var store: CategoryStore
    @State private var showDeleteConfirm = false

    private var userName: String? {
        if case .signedIn(_, let name) = authManager.authState { return name }
        return nil
    }

    private var isSignedIn: Bool {
        if case .signedIn = authManager.authState { return true }
        return false
    }

    var body: some View {
        NavigationView {
            List {
                // ── 계정 정보 ─────────────────────────────
                Section {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color(hex: "FEE500"))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Text((userName?.prefix(1)).map(String.init) ?? "?")
                                    .font(.title3).fontWeight(.bold)
                                    .foregroundColor(.black)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(userName ?? "비로그인 사용자")
                                .font(.headline)
                            Text(isSignedIn ? "Apple로 로그인됨" : "게스트 모드")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("계정")
                }

                // ── 앱 정보 ──────────────────────────────
                Section {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("앱 정보")
                }

                // ── 계정 관리 ─────────────────────────────
                Section {
                    if isSignedIn {
                        Button {
                            authManager.signOut()
                        } label: {
                            Text("로그아웃")
                                .foregroundColor(.orange)
                        }
                    }

                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Text("계정 삭제")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("계정 관리")
                } footer: {
                    Text("계정을 삭제하면 카테고리, 변환 기록 등 모든 데이터가 영구적으로 삭제됩니다.")
                }
            }
            .navigationTitle("설정")
            .alert("계정을 삭제하시겠습니까?", isPresented: $showDeleteConfirm) {
                Button("삭제", role: .destructive) {
                    authManager.deleteAccount()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("카테고리, 변환 기록 등 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthManager())
        .environmentObject(CategoryStore())
}
