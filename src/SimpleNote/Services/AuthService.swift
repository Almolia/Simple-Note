import Foundation
import Combine

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let baseURL = URL(string: "http://localhost:8000/api/")!
    
    func login(username: String, password: String) -> AnyPublisher<TokenResponse, Error> {
        let url = baseURL.appendingPathComponent("auth/token/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard
                    let response = output.response as? HTTPURLResponse,
                    response.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func signup(username: String, password:String, email: String, firstName: String? = nil, lastName: String? = nil) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("auth/register/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        if let firstName = firstName {
            body["first_name"] = firstName
        }
        
        if let lastName = lastName {
            body["last_name"] = lastName
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .eraseToAnyPublisher()
    }
}
