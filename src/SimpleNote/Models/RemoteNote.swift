import Foundation

struct RemoteNote: Decodable, Sendable {
    let id: Int
    let title: String
    let content: String
    let created_at: Date
    let updated_at: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case content = "description"
        case created_at
        case updated_at
    }
}

struct RemoteNotesResponse: Decodable, Sendable {
    let results: [RemoteNote]
}
