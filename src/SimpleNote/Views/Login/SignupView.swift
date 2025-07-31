import SwiftUI

struct SignupView: View {
    @Binding var path: NavigationPath

    @StateObject private var viewModel = AuthViewModel()

    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Register")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("and start taking notes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                VStack(alignment: .leading, spacing: 30) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Name")
                        TextField("Example: Taha", text: $firstName)
                            .textFieldStyle(MyTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Name")
                        TextField("Example: Hamifar", text: $lastName)
                            .textFieldStyle(MyTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Username")
                        TextField("Example: @HamifarTaha", text: $username)
                            .textFieldStyle(MyTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email Address")
                        TextField("Example: hamifar.taha@gmail.com", text: $email)
                            .textFieldStyle(MyTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                        SecureField("Password", text: $password)
                            .textFieldStyle(MyTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Retype Password")
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(MyTextFieldStyle())
                    }
                }
                
                Text(viewModel.errorMessage ?? " ")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 20) // Reserve minimum height
                    .opacity(viewModel.errorMessage != nil ? 1.0 : 0.0)
                
                Button(action: {
                    guard password == confirmPassword else {
                        viewModel.errorMessage = "Passwords do not match"
                        return
                    }
                    
                    viewModel.signup(
                        username: username,
                        email: email,
                        password: password,
                        firstName: firstName.isEmpty ? nil : firstName,
                        lastName: lastName.isEmpty ? nil : lastName
                    ) { success in
                        if success {
                            path.append(Route.notes)
                        }
                    }
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
                            Text("Register")
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
                
                Button(action: {
                    path.removeLast()
                }) {
                    Text("Already have an account? Login here")
                        .font(.footnote)
                        .foregroundColor(Color("snPurple"))
                }
                .padding(.bottom)
                .navigationBarBackButtonHidden(true)
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        path.removeLast()
                    }) {
                        Image(systemName: "chevron.backward")
                        Text("Back to Login")
                    }
                    .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20.0)
            .padding(.top, 40)
            .navigationBarBackButtonHidden(true)
            
        }
    }
    
    private var formIsValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
}



#Preview {
    StatefulPreviewWrapper(NavigationPath()) { path in
        SignupView(path: path)
    }
}
