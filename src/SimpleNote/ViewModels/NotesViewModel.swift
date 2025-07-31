import Foundation
import Combine


struct Note: Identifiable, Codable {
    let id: Int
    var title: String
    var description: String
    let created_at: Date
    var updated_at: Date
}

struct NotesResponse: Decodable {
    let results: [Note]
}
import Foundation
import Combine

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    // Call this when you want to load the initial notes list (GET)
    func fetchNotes() {
        isLoading = true
        NoteService.shared.fetchNotes(token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { notes in
                self.notes = notes
            })
            .store(in: &cancellables)
    }
    
    // Update a note in both backend and local list
    func update(note: Note) {
        guard let existing = notes.first(where: { $0.id == note.id }) else { return }
        guard existing.title != note.title || existing.description != note.description else { return }
        isUpdating = true
        errorMessage = nil        
        
        NoteService.shared.updateNote(note, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isUpdating = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Update failed: \(error.localizedDescription)"
                }
            }, receiveValue: {
                // If update was successful, replace the note locally
                if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                    self.notes[index] = note
                }
            })
            .store(in: &cancellables)
    }
    
    func delete(note: Note) {
        isUpdating = true
        errorMessage = nil
        
        NoteService.shared.deleteNote(withId: note.id, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isUpdating = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Delete failed: \(error.localizedDescription)"
                }
            }, receiveValue: {
                self.notes.removeAll { $0.id == note.id }
            })
            .store(in: &cancellables)
    }
    
    func create(title: String, description: String) {
        isUpdating = true
        errorMessage = nil
        
        NoteService.shared.createNote(title: title, description: description, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isUpdating = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Create failed: \(error.localizedDescription)"
                }
            }, receiveValue: { newNote in
                self.fetchNotes()
            })
            .store(in: &cancellables)
    }
}
