import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var message: String?
    
    @Published var user: User?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        validateSession()
    }
    
    func validateSession() {
        guard TokenManager.shared.getRefreshToken() != nil else {
            return
        }
        
        self.isLoading = true
        
        AuthService.shared.fetchUserProfile()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure = completion {
                    self.logout()
                }
            } receiveValue: { fetchedUser in
                self.user = fetchedUser
                self.isAuthenticated = true
            }
            .store(in: &cancellables)
    }
    
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        message = nil
        
        AuthService.shared.login(username: username, password: password)
            .flatMap { tokenResponse -> AnyPublisher<User, Error> in
                TokenManager.shared.saveTokens(tokenResponse)
                return AuthService.shared.fetchUserProfile()
            }
            .receive(on: DispatchQueue.main)
            .sink { completionSink in
                self.isLoading = false
                
                if case let .failure(error) = completionSink {
                    if let authError = error as? AuthError {
                        self.message = authError.localizedDescription
                    } else {
                        self.message = "An unexpected error occurred. Please check your connection."
                    }
                    completion(false)
                }
            } receiveValue: { fetchedUser in
                self.user = fetchedUser
                self.isAuthenticated = true
                completion(true)
            }
            .store(in: &cancellables)
    }
    
    
    func signup(username: String, email: String, password: String, firstName: String? = nil, lastName:String? = nil, completion:@escaping (Bool) -> Void) {
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
            self.login(username: username, password: password, completion: completion)
        }
        .store(in: &cancellables)
    }
    
    
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        message = nil
        
        AuthService.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
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
    
    
    func fetchUserProfile() {
        isLoading = true
        message = nil
        
        AuthService.shared.fetchUserProfile()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.message = "Failed to fetch profile: \(error.localizedDescription)"
                }
            } receiveValue: { fetchedUser in
                self.user = fetchedUser
            }
            .store(in: &cancellables)
    }
    
    
    func logout() {
        TokenManager.shared.clearTokens()
        self.isAuthenticated = false
        self.user = nil
    }
}
