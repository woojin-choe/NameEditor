import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ConvertView()
                .tabItem {
                    Label("이름 변환", systemImage: "text.cursor")
                }

            CategoryManagementView()
                .tabItem {
                    Label("카테고리", systemImage: "folder")
                }

            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
        }
        .accentColor(Color(hex: "FEE500"))
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().tintColor = UIColor(red: 0.99, green: 0.72, blue: 0.0, alpha: 1.0)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CategoryStore())
}
