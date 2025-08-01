import SwiftUI

struct ChangePasswordView: View {
    @Binding var path: NavigationPath
    @StateObject private var authViewModel = AuthViewModel(token: TokenManager.shared.getAccessToken() ?? "")
    
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()
                .padding(.vertical, 20)
            Text("Current Password")
                .font(.title2)
                .fontWeight(.semibold)
            SecureField("Current Password", text: $oldPassword)
                .textFieldStyle(MyTextFieldStyle())

            Spacer()
                .frame(height: 20)
            
            Text("New Password")
                .font(.title2)
                .fontWeight(.semibold)
            
            SecureField("New Password", text: $newPassword)
                .textFieldStyle(MyTextFieldStyle())
            
            Text("Password should contain a-z, A-Z, 0-9")
                .font(.footnote)
                .foregroundColor(Color.gray)
            
            Spacer()
                .frame(height: 20)

            Text("Confirm Password")
                .font(.title2)
                .fontWeight(.semibold)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(MyTextFieldStyle())

            Spacer()
            
            HStack{
                Spacer()
                if !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword != confirmPassword {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 20)
                } else if let message = authViewModel.message {
                    Text(message)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 20)
                } else {
                    Text(" ")
                        .frame(minHeight: 20)
                }
                Spacer()
            }
            
            Spacer()
                .frame(height: 20)
            
            Button(action: {
                authViewModel.changePassword(oldPassword: oldPassword, newPassword: newPassword) { success in
                    if success {
                        oldPassword = ""
                        newPassword = ""
                        confirmPassword = ""
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
                        Text("Submit New Password")
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
        }
        .padding(25)
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var formIsValid: Bool {
        !oldPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword
    }
}

#Preview {
    StatefulPreviewWrapper(NavigationPath()) { path in
        ChangePasswordView(path: path)
    }
}
