import Foundation
import Observation
import AuthenticationServices

enum AuthState {
    case unknown
    case signedIn(userID: String, name: String?)
    case guest
}

@Observable
class AuthManager {
    var authState: AuthState = .unknown

    private let userIDKey = "appleUserID"
    private let userNameKey = "appleUserName"
    private let isGuestKey = "isGuest"

    init() {
        restore()
    }

    // MARK: - Restore

    private func restore() {
        if UserDefaults.standard.bool(forKey: isGuestKey) {
            authState = .guest
            return
        }
        guard let userID = UserDefaults.standard.string(forKey: userIDKey) else {
            authState = .unknown
            return
        }
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { [weak self] state, _ in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    let name = UserDefaults.standard.string(forKey: self?.userNameKey ?? "")
                    self?.authState = .signedIn(userID: userID, name: name)
                default:
                    self?.authState = .unknown
                }
            }
        }
    }

    // MARK: - Sign In with Apple

    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            let userID = credential.user
            let nameParts = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            let name = nameParts.isEmpty ? nil : nameParts

            UserDefaults.standard.set(userID, forKey: userIDKey)
            if let name { UserDefaults.standard.set(name, forKey: userNameKey) }
            UserDefaults.standard.set(false, forKey: isGuestKey)

            authState = .signedIn(userID: userID, name: name)

        case .failure:
            break
        }
    }

    // MARK: - Guest

    func continueAsGuest() {
        UserDefaults.standard.set(true, forKey: isGuestKey)
        authState = .guest
    }

    // MARK: - Sign Out

    func signOut() {
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.set(false, forKey: isGuestKey)
        authState = .unknown
    }

    // MARK: - Delete Account

    func deleteAccount() {
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.set(false, forKey: isGuestKey)
        UserDefaults.standard.removeObject(forKey: "ktCategories")
        UserDefaults.standard.removeObject(forKey: "ktHistory")
        authState = .unknown
    }
}
