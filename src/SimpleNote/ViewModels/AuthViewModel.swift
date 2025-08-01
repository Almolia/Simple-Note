import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var message: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let token: String

    
    init(token: String) {
        self.token = token
    }
    
    // MARK: - Login
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        message = nil
        
        AuthService.shared.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completionSink in
                self.isLoading = false
                if case let .failure(error) = completionSink {
                    self.message = error.localizedDescription
                    completion(false)
                }
            } receiveValue: { tokenResponse in
                TokenManager.shared.saveTokens(tokenResponse)
                self.isAuthenticated = true
                completion(true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Signup
    func signup(
        username: String,
        email: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        isLoading = true
        message = nil
        
        AuthService.shared.signup(
            username: username,
            password: password,
            email: email,
            firstName: firstName,
            lastName: lastName
        )
        .receive(on: DispatchQueue.main)
        .sink { completionSink in
            self.isLoading = false
            if case let .failure(error) = completionSink {
                self.message = error.localizedDescription
                completion(false)
            }
        } receiveValue: { _ in
            // Automatically login after successful signup
            self.login(username: username, password: password, completion: completion)
        }
        .store(in: &cancellables)
    }
    
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        message = nil

        AuthService.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword, token: token)
            .receive(on: DispatchQueue.main)
            .sink { completionSink in
                self.isLoading = false
                if case let .failure(error) = completionSink {
                    self.message = error.localizedDescription
                    completion(false)
                }
            } receiveValue: { _ in
                self.message = "Password Changed Successfully!"
                completion(true)

            }
            .store(in: &cancellables)
    }
}
