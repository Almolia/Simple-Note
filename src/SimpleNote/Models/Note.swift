import Foundation
import SwiftData

@Model
final class Note: Sendable {
    @Attribute(.unique)
    var id: Int
    var title: String
    var content: String
    var created_at: Date
    var updated_at: Date
    
    init(id: Int, title: String, content: String, created_at: Date, updated_at: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.created_at = created_at
        self.updated_at = updated_at
    }
}
