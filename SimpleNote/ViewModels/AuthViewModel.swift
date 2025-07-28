import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Login
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        AuthService.shared.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { tokenResponse in
                TokenManager.shared.saveTokens(tokenResponse)
                self.isAuthenticated = true
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
        errorMessage = nil
        
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
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        } receiveValue: { _ in
            completion(true)
        }
        .store(in: &cancellables)
    }
}
