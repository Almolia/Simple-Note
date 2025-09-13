import SwiftUI
import SwiftData

enum Routes: Hashable {
    case login
    case signup
    case notes
    case edit(Note)
    case create
    case profile
}


struct MainAppView: View {
    @State private var path = NavigationPath()
    
    @StateObject private var notesViewModel: NotesViewModel
    
    init(modelContext: ModelContext) {
        _notesViewModel = StateObject(wrappedValue: NotesViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            NotesListView(path: $path)
                .navigationDestination(for: Routes.self) { route in
                    switch route {
                    case .edit(let note):
                        NoteEditorView(mode: .edit(note), path: $path)
                    case .create:
                        NoteEditorView(mode: .create, path: $path)
                    case .profile:
                        ProfileView(path: $path)
                    default:
                        EmptyView()
                    }
                }
        }
        .environmentObject(notesViewModel)
    }
}
