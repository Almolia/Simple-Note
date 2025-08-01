import SwiftUI

struct SignupView: View {
    @Binding var path: NavigationPath

    @StateObject private var authViewModel = AuthViewModel(token: TokenManager.shared.getAccessToken() ?? "")
    
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
                
                Text(authViewModel.message ?? " ")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 20) // Reserve minimum height
                    .opacity(authViewModel.message != nil ? 1.0 : 0.0)
                
                Button(action: {
                    guard password == confirmPassword else {
                        authViewModel.message = "Passwords do not match"
                        return
                    }
                    
                    authViewModel.signup(
                        username: username,
                        email: email,
                        password: password,
                        firstName: firstName.isEmpty ? nil : firstName,
                        lastName: lastName.isEmpty ? nil : lastName
                    ) { success in
                        if success {
                            path.append(Routes.notes)
                        }
                    }
                }) {
                    HStack {
                        if authViewModel.isLoading {
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
                .disabled(!formIsValid || authViewModel.isLoading)
                
                Button(action: {
                    path.removeLast()
                }) {
                    Text("Already have an account? Login here")
                        .font(.footnote)
                        .foregroundColor(Color("snPurple"))
                }
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20.0)
            .padding(.top, 40)
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
