import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainAppView(modelContext: modelContext)
            } else {
                IntroLoginFlow()
            }
        }
        .environmentObject(authViewModel)
    }
}

// MARK: - Pre-Authentication Flow

struct IntroLoginFlow: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            // حالا ContentView این ساختار را می‌شناسد
            IntroViewContents(path: $path)
                .navigationDestination(for: Routes.self) { route in
                    switch route {
                    case .login:
                        LoginView(path: $path)
                    case .signup:
                        SignupView(path: $path)
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

// *** تعریف IntroViewContents به این فایل منتقل شد ***
struct IntroViewContents: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color("snPurple").ignoresSafeArea() // بهتر است از Color Assets استفاده کنید
            VStack {
                Spacer()
                Image("Intro")
                    .resizable().aspectRatio(contentMode: .fit).padding(.all)
                Text("Jot Down anything you want to achieve, today or in the future")
                    .fontWeight(.bold).foregroundColor(.white).multilineTextAlignment(.center)
                    .font(.system(size: 25)).padding(.horizontal).lineSpacing(8)
                Spacer()
                Button(action: {
                    path.append(Routes.login)
                }) {
                    HStack {
                        Image(systemName: "arrow.right").hidden()
                        Spacer()
                        Text("Let's Get Started").font(.headline).foregroundColor(Color(red: 0.315, green: 0.306, blue: 0.764))
                        Spacer()
                        Image(systemName: "arrow.right").foregroundColor(Color(red: 0.315, green: 0.306, blue: 0.764))
                    }
                    .padding(.all, 20.0).background(Color.white).cornerRadius(30)
                }
                .padding(.horizontal)
                .disabled(authViewModel.isLoading)
                Spacer()
            }
        }
    }
}
