import SwiftUI

enum ProfileRoute: Hashable {
    case changePassword
}


struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Binding var path: NavigationPath
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            // Profile Info
            if let user = authViewModel.user {
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(user.first_name ?? "") \(user.last_name ?? "")".trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? user.username : "\(user.first_name!) \(user.last_name!)")
                            .font(.title)
                        HStack {
                            Image(systemName: "envelope")
                            Text(user.email)
                                .font(.subheadline)
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            } else if authViewModel.isLoading {
                ProgressView("Loading Profile...")
            }
            
            Divider()
            
            Text("APP SETTINGS")
                .font(.footnote)
                .foregroundColor(.gray)
            
            
            // Change Password Button
            Button(action: {
                // Action for changing password
                path.append(ProfileRoute.changePassword)
            }) {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Change Password")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
            }
            
            Divider()
            
            // Logout Button
            Button(action: {
                showLogoutConfirmation = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.forward")
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
            }
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
            case .changePassword:
                ChangePasswordView(path: $path)
            }
        }
        .confirmationDialog(
            "Are you sure you want to log out?",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ){
            Button("Log Out", role: .destructive) {
                
                authViewModel.logout()
                path = NavigationPath()
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .onAppear {
            if authViewModel.user == nil {
                authViewModel.fetchUserProfile()
            }
        }
    }
}
