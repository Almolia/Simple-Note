import Foundation
import SwiftData
import Combine

@MainActor
class NoteRepository {
    
    private let modelContext: ModelContext
    
    private let noteService: NoteService
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.noteService = NoteService.shared
    }
    
    // MARK: - Core Data Operations
    
    func syncNotesFromServer() async {
        do {
            let remoteNotes = try await noteService.fetchNotes().async()
            
            for remoteNote in remoteNotes {
                let id = remoteNote.id
                var fetchDescriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.id == id })
                fetchDescriptor.fetchLimit = 1
                
                if let existingLocalNote = try modelContext.fetch(fetchDescriptor).first {
                    existingLocalNote.title = remoteNote.title
                    existingLocalNote.content = remoteNote.content
                    existingLocalNote.updated_at = remoteNote.updated_at
                } else {
                    let newLocalNote = Note(
                        id: remoteNote.id,
                        title: remoteNote.title,
                        content: remoteNote.content,
                        created_at: remoteNote.created_at,
                        updated_at: remoteNote.updated_at
                    )
                    modelContext.insert(newLocalNote)
                }
            }
            
            let remoteNoteIDs = Set(remoteNotes.map { $0.id })
            let allLocalNotes = try modelContext.fetch(FetchDescriptor<Note>())
            for localNote in allLocalNotes where !remoteNoteIDs.contains(localNote.id) {
                modelContext.delete(localNote)
            }
            
        } catch {
            print("Failed to sync notes from server: \(error.localizedDescription)")
        }
    }
    
    func createNote(title: String, content: String) async {
        let tempID = -Int(Date().timeIntervalSince1970)
        let newNote = Note(
            id: tempID,
            title: title,
            content: content,
            created_at: Date(),
            updated_at: Date()
        )
        
        modelContext.insert(newNote)
        
        do {
            let createdRemoteNote = try await noteService.createNote(title: title, content: content).async()
            newNote.id = createdRemoteNote.id
        } catch {
            print("Failed to create note on server: \(error.localizedDescription)")
        }
    }
    
    func updateNote(_ note: Note) async {
        
        do {
            try await noteService.updateNote(note).async()
        } catch {
            print("Failed to update note on server: \(error.localizedDescription)")
        }
    }
    
    func deleteNote(_ note: Note) async {
        let noteID = note.id
        
        modelContext.delete(note)
        
        guard noteID > 0 else { return }
        
        do {
            try await noteService.deleteNote(withId: noteID).async()
        } catch {
            print("Failed to delete note on server: \(error.localizedDescription)")
        }
    }
}


extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}
