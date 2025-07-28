import SwiftUI


struct NotesListView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var searchText: String = ""
    
    var body: some View {
        // Main ZStack to layer content
        ZStack(alignment: .bottom) {
            // Primary content area
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading notes...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else if viewModel.notes.isEmpty {
                    // Empty State View...
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
                        
                        VStack(spacing: 8) {
                            Text("Every big step starts with a small step.")
                            Text("Note your first idea and start")
                            Text("your journey!")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        Image("Arrow")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal, 80)
                            .padding(.top, 40)
                        Spacer()
                    }
                    .padding(.bottom, 80)
                } else {
                    // Scrollable notes list
                    ScrollView {
                        VStack(spacing: 0) {
                            HStack {
                                Text("My Notes")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
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
                            
                            let columns = [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.notes.filter {
                                    searchText.isEmpty ||
                                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                                    $0.description.localizedCaseInsensitiveContains(searchText)
                                }) { note in
                                    NoteRowView(note: note)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        .padding(.bottom, 120)
                    }
                    .overlay(
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 70)
                            .ignoresSafeArea(edges: .top),
                        
                        alignment: .top
                    )
                    

                }
            }
            .padding(.horizontal)
            
            ZStack{
                // Fixed bottom navigation bar
                HStack {
                    VStack(spacing: 4) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("snPurple"))
                        Text("Home")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color("snPurple"))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                        Text("Settings")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 50)
                .frame(height: 70)
                .background(Color("downBar")
                .ignoresSafeArea(edges: .bottom))
                .overlay(Divider(), alignment: .top)
                
                // Fixed floating action button
                Button(action: {
                    // Add note action
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(circleButtonStyle())
                .padding(.bottom, 70) // Position above bottom bar
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            if viewModel.notes.isEmpty, let token = TokenManager.shared.getAccessToken() {
                viewModel.loadNotes(token: token)
            }
        }
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
