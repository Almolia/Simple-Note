import Foundation
import Combine

class NoteService {
    static let shared = NoteService()
    private init() {}
    
    private let baseURL = URL(string: "http://localhost:8000/api/")!
    
    private var customDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Invalid date format: \(dateString)")
        }
        return decoder
    }
    
    func fetchNotes() -> AnyPublisher<[RemoteNote], Error> {
        let url = baseURL.appendingPathComponent("notes/")
        let request = URLRequest(url: url)
        
        return AuthService.shared.performRequest(with: request)
            .decode(type: RemoteNotesResponse.self, decoder: customDecoder)
            .map { $0.results }
            .eraseToAnyPublisher()
    }
    
    func createNote(title: String, content: String) -> AnyPublisher<RemoteNote, Error> {
        let url = baseURL.appendingPathComponent("notes/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["title": title, "description": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return AuthService.shared.performRequest(with: request)
            .decode(type: RemoteNote.self, decoder: customDecoder)
            .eraseToAnyPublisher()
    }
    
    func updateNote(_ note: Note) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("notes/\(note.id)/")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["title": note.title, "description": note.content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return AuthService.shared.performRequest(with: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func deleteNote(withId id: Int) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("notes/\(id)/")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return AuthService.shared.performRequest(with: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
