import Foundation

class TokenManager {
    static let shared = TokenManager()
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"

    private init() {}

    func saveTokens(_ tokens: TokenResponse) {
        UserDefaults.standard.set(tokens.accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(tokens.refreshToken, forKey: refreshTokenKey)
    }

    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }

    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}
