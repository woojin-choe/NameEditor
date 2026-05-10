//
//  name_editorApp.swift
//  name_editor
//
//  Created by 최우진 on 4/15/26.
//

import SwiftUI

@main
struct name_editorApp: App {
    @State private var store = CategoryStore()
    @State private var authManager = AuthManager()
    @State private var showSplash = true
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeOut(duration: 0.4)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                switch authManager.authState {
                case .unknown:
                    LoginView()
                        .environment(authManager)
                case .signedIn, .guest:
                    if showOnboarding {
                        OnboardingView {
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                            withAnimation(.easeOut(duration: 0.4)) {
                                showOnboarding = false
                            }
                        }
                    } else {
                        ContentView()
                            .environmentObject(store)
                            .environment(authManager)
                    }
                }
            }
        }
    }
}
