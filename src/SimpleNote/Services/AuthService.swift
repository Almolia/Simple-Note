import Foundation
import Combine

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let baseURL = URL(string: "http://localhost:8000/api/")!
    
    // MARK: - Token Refresh Logic
    
    private func refreshToken() -> AnyPublisher<Void, Error> {
        guard let refreshToken = TokenManager.shared.getRefreshToken() else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        let url = baseURL.appendingPathComponent("auth/token/refresh/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["refresh": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.userAuthenticationRequired)
                }
                return output.data
            }
            .decode(type: AccessTokenResponse.self, decoder: JSONDecoder())
            .map { tokenResponse in
                TokenManager.shared.saveAccessToken(tokenResponse.access)
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    func performRequest(with originalRequest: URLRequest) -> AnyPublisher<Data, Error> {
        guard let token = TokenManager.shared.getAccessToken() else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        
        var request = originalRequest
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if httpResponse.statusCode == 401 {
                    throw URLError(.userAuthenticationRequired)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .catch { error -> AnyPublisher<Data, Error> in
                if let urlError = error as? URLError, urlError.code == .userAuthenticationRequired {
                    return self.refreshToken()
                        .flatMap {
                            return self.performRequest(with: originalRequest)
                        }
                        .eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Public API Methods
    
    func login(username: String, password: String) -> AnyPublisher<TokenResponse, Error> {
        let url = baseURL.appendingPathComponent("auth/token/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw AuthError.unknown
                }
                
                if response.statusCode == 401 || response.statusCode == 400 {
                    throw AuthError.invalidCredentials
                }
                
                guard (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                return output.data
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                if error is DecodingError {
                    return AuthError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func signup(username: String, password:String, email: String, firstName: String? = nil, lastName: String? = nil) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("auth/register/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = ["username": username, "email": email, "password": password]
        if let firstName = firstName { body["first_name"] = firstName }
        if let lastName = lastName { body["last_name"] = lastName }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    func changePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("auth/change-password/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["old_password": oldPassword, "new_password": newPassword]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return performRequest(with: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func fetchUserProfile() -> AnyPublisher<User, Error> {
        let url = baseURL.appendingPathComponent("auth/userinfo/")
        let request = URLRequest(url: url)
        
        return performRequest(with: request)
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
