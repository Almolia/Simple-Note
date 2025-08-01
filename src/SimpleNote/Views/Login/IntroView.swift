import SwiftUI

enum Routes: Hashable {
    case login
    case signup
    case notes
    case edit(Int)
    case create
    case profile
}

struct IntroView: View {
    @State private var path = NavigationPath()
    @StateObject private var authViewModel = AuthViewModel(token: TokenManager.shared.getAccessToken() ?? "")
    
    @StateObject private var notesViewModel = NotesViewModel(token: TokenManager.shared.getAccessToken() ?? "")
    
    
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
                            path.append(Routes.notes)
                        } else {
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
                        .background(Color.white)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .navigationDestination(for: Routes.self) { route in
                navigationDestination(for: route)
            }
        }
    }
    
    @ViewBuilder
    private func navigationDestination(for route: Routes) -> some View {
        switch route {
        case .login:
            LoginView(path: $path)
            
            
        case .signup:
            SignupView(path: $path)
            
            
        case .notes:
            NotesListView(path: $path)
            
            
            
        case .edit(let id):
            if let index = notesViewModel.notes.firstIndex(where: { $0.id == id }) {
                NoteEditorView(
                    mode: .edit(notesViewModel.notes[index]),
                    path: $path,
                    onDelete: {
                        notesViewModel.delete(note: notesViewModel.notes[index])
                    },
                    onSave: { updatedNote in
                        notesViewModel.update(note: updatedNote)
                    },
                    onSaveCreate: { _, _ in }
                )
                
            }
        case .create:
            NoteEditorView(
                mode: .create,
                path: $path,
                onDelete: {},
                onSave: { _ in },
                onSaveCreate: { title, description in
                    notesViewModel.create(title: title, description: description)
                }
            )
            
        case .profile:
            ProfileView(path: $path)
        }
    }
}

#Preview {
    IntroView()
}
