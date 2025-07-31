import SwiftUI

enum NoteRoute: Hashable {
    case edit(Int)
    case create
}


struct NotesListView: View {
    @StateObject private var viewModel = NotesViewModel(token: TokenManager.shared.getAccessToken() ?? "")
    @State private var searchText: String = ""
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                mainContentView
                bottomNavigationView
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationDestination(for: NoteRoute.self) { route in
                navigationDestination(for: route)
            }
            .onAppear {
                loadNotesIfNeeded()
            }
            .onChange(of: path) {
                print(path)
            }
        }
    }
    
    // MARK: - Main Content View
    @ViewBuilder
    private var mainContentView: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error: error)
            } else if viewModel.notes.isEmpty {
                emptyStateView
            } else {
                notesListView
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            ProgressView("Loading notes...")
            Spacer()
        }
    }
    
    // MARK: - Error View
    private func errorView(error: String) -> some View {
        VStack {
            Text("Error: \(error)")
                .foregroundColor(.red)
                .padding()
            Spacer()
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("Journey_Illustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 30)
            
            Text("Start Your Journey")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 20)
            
            emptyStateDescription
            
            Image("Arrow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 80)
                .padding(.top, 40)
            
            Spacer()
        }
        .padding(.bottom, 80)
    }
    
    private var emptyStateDescription: some View {
        VStack(spacing: 8) {
            Text("Every big step starts with a small step.")
            Text("Note your first idea and start")
            Text("your journey!")
        }
        .font(.system(size: 16))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    
    // MARK: - Notes List View
    private var notesListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                searchBarView
                notesGridView
            }
            .padding(.bottom, 120)
        }
        .overlay(topOverlay, alignment: .top)
    }
    
    private var headerView: some View {
        HStack {
            Text("My Notes")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var searchBarView: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var notesGridView: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(filteredNotes) { note in
                NoteRowView(note: note)
                    .onTapGesture {
                        path.append(NoteRoute.edit(note.id))
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var filteredNotes: [Note] {
        viewModel.notes.filter { note in
            searchText.isEmpty ||
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var topOverlay: some View {
        Rectangle()
            .fill(Color.white)
            .frame(height: 70)
            .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Bottom Navigation View
    private var bottomNavigationView: some View {
        ZStack {
            bottomTabBar
            floatingActionButton
        }
    }
    
    private var bottomTabBar: some View {
        HStack {
            tabBarItem(
                icon: "house.fill",
                title: "Home",
                color: Color("snPurple")
            )
            
            Spacer()
            
            tabBarItem(
                icon: "gearshape",
                title: "Settings",
                color: .gray
            )
        }
        .padding(.horizontal, 50)
        .frame(height: 70)
        .background(
            Color("downBar")
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(Divider(), alignment: .top)
    }
    
    private func tabBarItem(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
        }
    }
    
    private var floatingActionButton: some View {
        Button(action: {
            path.append(NoteRoute.create)
        }) {
            Image(systemName: "plus")
        }
        .buttonStyle(circleButtonStyle())
        .padding(.bottom, 70)
    }
    
    // MARK: - Navigation
    @ViewBuilder
    private func navigationDestination(for route: NoteRoute) -> some View {
        switch route {
        case .edit(let id):
            if let index = viewModel.notes.firstIndex(where: { $0.id == id }) {
                NoteEditorView(
                    mode: .edit(viewModel.notes[index]),
                    path: $path,
                    onDelete: {
                        viewModel.delete(note: viewModel.notes[index])
                    },
                    onSave: { updatedNote in
                        viewModel.update(note: updatedNote)
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
                    viewModel.create(title: title, description: description)
                }
            )
        }
    }
    
    // MARK: - Helper Methods
    private func loadNotesIfNeeded() {
        viewModel.fetchNotes()
    }
}

// MARK: - Note Row View
struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .truncationMode(.tail)
                .padding(.vertical)
            
            Text(note.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(7)
                .truncationMode(.tail)
        }
        .padding(.horizontal)
        .frame(width: 160, height: 200, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(randomPastelColor())
        )
    }

    private func randomPastelColor() -> Color {
        let pastelColors: [Color] = [
            Color(red: 0.9, green: 0.8, blue: 1.0),
            Color(red: 0.8, green: 1.0, blue: 0.8),
            Color(red: 1.0, green: 0.9, blue: 0.8),
            Color(red: 1.0, green: 0.95, blue: 0.7),
            Color(red: 0.8, green: 0.95, blue: 1.0)
        ]
        return pastelColors.randomElement() ?? .blue
    }
}

// MARK: - Circle Button Style
struct circleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.system(size: 30))
            .background(
                Circle()
                    .stroke(Color.white, lineWidth: 5)
                    .background(
                        Circle()
                            .fill(Color("snPurple"))
                    )
                    .frame(width: 66, height: 66)
            )
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
    }
}

#Preview {
    NotesListView()
}
