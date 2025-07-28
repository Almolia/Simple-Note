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

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: NotesResponse.self, decoder: JSONDecoder())
            .map { $0.results }  // ✅ now it's [Note]
            .eraseToAnyPublisher()
    }
}
