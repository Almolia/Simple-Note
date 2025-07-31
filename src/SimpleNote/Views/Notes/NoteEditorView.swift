import SwiftUI

enum EditorMode {
    case create
    case edit(Note)
}

struct NoteEditorView: View {
    var mode: EditorMode
    var onDelete: () -> Void
    var onSave: (Note) -> Void
    var onSaveCreate: (String, String) -> Void
    @Binding var path: NavigationPath
    @State private var editedText: String
    @State private var editedTitle: String
    @State private var showDeleteConfirmation = false
    @State private var shouldSave = true
    @Environment(\.dismiss) private var dismiss
    
    init(mode: EditorMode, path: Binding<NavigationPath>, onDelete: @escaping () -> Void, onSave: @escaping (Note) -> Void, onSaveCreate: @escaping (String, String) -> Void) {
        self.mode = mode
        _path = path
        self.onDelete = onDelete
        self.onSave = onSave
        self.onSaveCreate = onSaveCreate
        switch mode {
        case .create:
            _editedTitle = State(initialValue: "")
            _editedText = State(initialValue: "")
        case .edit(let note):
            _editedTitle = State(initialValue: note.title)
            _editedText = State(initialValue: note.description)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack{
                    TextField("Title", text: $editedTitle)
                        .font(.title)
                        .bold()
                    
                    Divider()
                    
                    // TextEditor with placeholder
                    ZStack(alignment: .topLeading) {
                        if editedText.isEmpty {
                            Text("Enter your note here...")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                                .padding(.top, 8)
                        }
                        TextEditor(text: $editedText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .font(.system(size: 20))
                            .opacity(editedText.isEmpty ? 0.25 : 1)
                    }
                }
                .padding(.horizontal)
                
                
                if case .edit(let note) = mode {
                    // Footer with last edited date and delete button
                    Divider()
                    HStack {
                        Text("\(formattedLastEditDate(note.updated_at))")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash").resizable()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color("snPurple"))
                                )
                        }
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color("downBar"))
                }
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
                switch mode {
                case .create:
                    onSaveCreate(editedTitle, editedText)
                case .edit(let note):
                    var updatedNote = note
                    updatedNote.title = editedTitle
                    updatedNote.description = editedText
                    updatedNote.updated_at = Date()
                    onSave(updatedNote)
                }
            }
        }
    }
    
    private func formattedLastEditDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        // For dates today: Show time only (e.g., "Edited 14:30")
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return "Last Edited at " + formatter.string(from: date)
        }
        // For dates this year: Show day + month + time (e.g., "15 Jun, 14:30")
        else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "d MMM, HH:mm"
            return formatter.string(from: date)
        }
        // For older dates: Show full date + time (e.g., "15 Jun 2023, 14:30")
        else {
            formatter.dateFormat = "d MMM yyyy, HH:mm"
            return formatter.string(from: date)
        }
    }
}
