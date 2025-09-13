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

struct IntroView: View {
    @State private var path = NavigationPath()
    
    @StateObject private var authViewModel = AuthViewModel()
    
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(red: 80 / 255, green: 78 / 255, blue: 195 / 255).ignoresSafeArea()
                VStack {
                    Spacer()
                    Image("Intro")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.all)
                    Text("Jot Down anything you want to achieve, today or in the future")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 25))
                        .padding(.horizontal)
                        .lineSpacing(8)
                    Spacer()
                    Button(action: {
                        if authViewModel.isAuthenticated {
                            print("Moshkel az injast")
                            path.append(Routes.notes)
                        } else {
                            print("Na Ok shod")
                            path.append(Routes.login)
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right")
                                .hidden()
                            Spacer()
                            Text("Let's Get Started")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.315, green: 0.306, blue: 0.764))
                                .frame(maxWidth: .infinity) // Expands to fill available space
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(Color(red: 0.315, green: 0.306, blue: 0.764))
                        }
                        .padding(.all, 20.0)
                        .disabled(authViewModel.isLoading)
                        .background(Color.white)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .navigationDestination(for: Routes.self) { route in
                resolve(route: route)
            }
        }
        .environmentObject(authViewModel)
    }
    @ViewBuilder
    private func resolve(route: Routes) -> some View {
        @Environment(\.modelContext) var modelContext
        
        switch route {
        case .login:
            LoginView(path: $path)
            
        case .signup:
            SignupView(path: $path)
            
        case .notes:
            NotesListView(
                notesViewModel: NotesViewModel(modelContext: modelContext),
                path: $path
            )
            
        case .edit(let note):
            NoteEditorView(
                mode: .edit(note),
                path: $path,
                viewModel: NotesViewModel(modelContext: modelContext)
            )
            
        case .create:
            NoteEditorView(
                mode: .create,
                path: $path,
                viewModel: NotesViewModel(modelContext: modelContext)
            )
            
        case .profile:
            ProfileView(path: $path)
        }
    }
}


struct MainAppView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            // ما از یک نمای واسطه استفاده می‌کنیم تا بتوانیم modelContext را بگیریم
            NotesListViewWrapper(path: $path)
                .navigationDestination(for: Routes.self) { route in
                    resolve(route: route, path: $path)
                }
        }
    }

    @ViewBuilder
    private func resolve(route: Routes, path: Binding<NavigationPath>) -> some View {
        @Environment(\.modelContext) var modelContext
        
        switch route {
        case .notes:
            // این case دیگر لازم نیست چون نمای ریشه است
            // اما برای کامل بودن آن را نگه می‌داریم
            NotesListViewWrapper(path: path)
        case .edit(let note):
            NoteEditorView(
                viewModel: NotesViewModel(modelContext: modelContext),
                mode: .edit(note),
                path: path
            )
        case .create:
            NoteEditorView(
                viewModel: NotesViewModel(modelContext: modelContext),
                mode: .create,
                path: path
            )
        case .profile:
            ProfileView(path: path)
        
        // login و signup در این پشته ناوبری نیستند
        case .login, .signup:
            EmptyView()
        }
    }
}

// این نمای کوچک و کمکی به ما اجازه می‌دهد modelContext را بگیریم
// و آن را به NotesViewModel پاس دهیم.
struct NotesListViewWrapper: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var path: NavigationPath
    
    var body: some View {
        NotesListView(
            notesViewModel: NotesViewModel(modelContext: modelContext),
            path: $path
        )
    }
}
