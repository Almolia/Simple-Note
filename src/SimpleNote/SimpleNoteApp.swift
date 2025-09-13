import SwiftUI
import SwiftData

@main
struct SimpleNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)
        
    }
}
