import Foundation
import SwiftData


@MainActor
class NotesViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String?
    
    private let repository: NoteRepository
    
    init(modelContext: ModelContext) {
        self.repository = NoteRepository(modelContext: modelContext)
    }
    
    // MARK: - Public Facing Methods
    
    func syncNotes() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await repository.syncNotesFromServer()
            isLoading = false
        }
    }
    
    func createNote(title: String, content: String) {
        errorMessage = nil
        isUpdating = true
        
        Task {
            await repository.createNote(title: title, content: content)
            isUpdating = false
        }
    }
    
    func updateNote(_ note: Note) {
        errorMessage = nil
        isUpdating = true
        
        Task {
            await repository.updateNote(note)
            isUpdating = false
        }
    }
    
    func deleteNote(_ note: Note) {
        errorMessage = nil
        isUpdating = true
        
        Task {
            await repository.deleteNote(note)
            isUpdating = false
        }
    }
}
