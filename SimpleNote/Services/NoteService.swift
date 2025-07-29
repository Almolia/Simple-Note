import Foundation
import Combine
class NoteService {
    static let shared = NoteService()
    private init() {}
    
    private let baseURL = URL(string: "http://localhost:8000/api/")!
    
    func fetchNotes(token: String) -> AnyPublisher<[Note], Error> {
        let url = baseURL.appendingPathComponent("notes/")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: NotesResponse.self, decoder: decoder)
            .map { $0.results }
            .eraseToAnyPublisher()
    }
    
    func updateNote(_ note: Note, token: String) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("notes/\(note.id)/")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"  // or "PUT", depending on API
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["title": note.title, "description": note.description]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard
                    let response = output.response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteNote(withId id: Int, token: String) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("notes/\(id)/")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard
                    let response = output.response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                else {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .eraseToAnyPublisher()
    }
}
