import SwiftUI


struct NoteEditorView: View {
    @Binding var note: Note
    var onDelete: () -> Void
    var onSave: (Note) -> Void
    @Binding var path: NavigationPath
    @State private var editedText: String
    @State private var editedTitle: String
    @State private var showDeleteConfirmation = false
    @State private var shouldSave = true
    @Environment(\.dismiss) private var dismiss

    init(note: Binding<Note>, path: Binding<NavigationPath>, onDelete: @escaping () -> Void, onSave: @escaping (Note) -> Void) {
        _path = path
        _note = note
        self.onDelete = onDelete
        self.onSave = onSave
        _editedText = State(initialValue: note.wrappedValue.description)
        _editedTitle = State(initialValue: note.wrappedValue.title)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Title TextField (fixed at the top)
                TextField("Title", text: $editedTitle)
                    .font(.title)
                    .bold()
                    .padding([.top, .horizontal])
                
                // TextEditor (takes remaining space)
                TextEditor(text: $editedText)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Footer with last edited date and delete button
                Divider()
                HStack {
                    Text("Last edited: \(formattedDate(note.updated_at))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("snPurple"))
                            )
                    }
                    .padding(.trailing, 4)
                }
                .padding()
                .background(Color("downBar"))
            }
            .blur(radius: showDeleteConfirmation ? 3 : 0)
            .disabled(showDeleteConfirmation)
            
            // Custom delete confirmation popup
            if showDeleteConfirmation {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDeleteConfirmation = false
                    }
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Want to Delete this Note?")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showDeleteConfirmation = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Delete button
                    Button(action: {
                        shouldSave = false
                        onDelete()
                        path = NavigationPath()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trash")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            
                            Text("Delete Note")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    }
                    .background(Color.clear)
                    
                    Spacer().frame(height: 20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal, 40)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if shouldSave {
                var updatedNote = note
                updatedNote.title = editedTitle
                updatedNote.description = editedText
                updatedNote.updated_at = Date()
                onSave(updatedNote)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}//#Preview {
//    StatefulPreviewWrapper(NavigationPath()) { path in
//        NoteEditorView(path: path)
//    }
//}
