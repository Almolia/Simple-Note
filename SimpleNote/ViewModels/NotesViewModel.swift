import Foundation
import Combine


struct Note: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
}

struct NotesResponse: Decodable {
    let results: [Note]
}

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func loadNotes(token: String) {
        isLoading = true
        errorMessage = nil

        NoteService.shared.fetchNotes(token: token)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { notes in
                self.notes = notes
            }
            .store(in: &cancellables)
    }
}
