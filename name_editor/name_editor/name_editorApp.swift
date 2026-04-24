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
                    ContentView()
                        .environmentObject(store)
                        .environment(authManager)
                }
            }
        }
    }
}
