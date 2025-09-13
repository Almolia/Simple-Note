import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError(description: String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Incorrect username and/or password."
        case .networkError(let description):
            return "A network error occurred: \(description)"
        case .decodingError:
            return "A serverside problem occured."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
