import SwiftUI

enum ProfileRoute: Hashable {
    case changePassword
}


struct ProfileView: View {
    @Binding var path: NavigationPath

    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            // Profile Info
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("John Doe")
                        .font(.title)
                    HStack {
                        Image(systemName: "envelope")
                        Text("\("john.doe@example.com")")
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
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
                // Action for logout
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
    }
}

#Preview {
    StatefulPreviewWrapper(NavigationPath()) { path in
        ProfileView(path: path)
    }
}
