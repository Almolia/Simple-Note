import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Binding var path: NavigationPath
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showNotesStack = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Let's Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("and note your ideas!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 40.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Username")
                TextField("Username", text: $username)
                    .textFieldStyle(MyTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Password")
                SecureField("Password", text: $password)
                    .textFieldStyle(MyTextFieldStyle())
            }
            
            Text(viewModel.errorMessage ?? " ")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .frame(minHeight: 20)
                .opacity(viewModel.errorMessage != nil ? 1.0 : 0.0)
            
            Button(action: {
                viewModel.login(username: username, password: password)
            }) {
                HStack {
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.right")
                            .hidden()
                        Spacer()
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    }
                    
                }
                .padding()
                .background(formIsValid ? Color("snPurple") : Color.gray)
                .cornerRadius(25)
            }
            .disabled(!formIsValid || viewModel.isLoading)
            
            HStack {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 1)
                
                Text("or")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 1)
            }
            .padding(.all, 20.0)
            .cornerRadius(30)
            
            
            Button("Don't have any account? Register here") {
                path.append(Route.signup)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.top, .leading, .trailing], 30)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.isAuthenticated) {
            if viewModel.isAuthenticated {
                showNotesStack = true
            }
        }
        .fullScreenCover(isPresented: $showNotesStack) {
            NavigationStack {
                NotesListView()
            }
        }
    }
    
    private var formIsValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
}

#Preview {
    StatefulPreviewWrapper(NavigationPath()) { path in
        LoginView(path: path)
    }
}
