//
//  IntroView.swift
//  SimpleNote
//
//  Created by Ali M.Sh on 5/2/1404 AP.
//
enum Route: Hashable {
    case login
    case signup
    case notes
}

import SwiftUI

struct IntroView: View {
    @State private var path = NavigationPath()


    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(red: 80 / 255, green: 78 / 255, blue: 195 / 255).ignoresSafeArea()
                VStack {
                    Spacer()
                    Image("Intro")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.all)
                    Text("Jot Down anything you want to achieve, today or in the future")
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 25))
                        .padding(.horizontal)
                        .lineSpacing(8)
                    Spacer()
                    Button(action: {
                        path.append(Route.login)
                    }) {
                        HStack {
                            Image(systemName: "arrow.right")
                                .hidden()
                            Spacer()
                            Text("Let's Get Started")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.315, green: 0.306, blue: 0.764))
                                .frame(maxWidth: .infinity) // Expands to fill available space
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(Color(red: 0.315, green: 0.306, blue: 0.764))
                        }
                        .padding(.all, 20.0)
                        .background(Color.white)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .login:
                        LoginView(path: $path)
                    case .signup:
                        SignupView(path: $path)
                    case .notes:
                        NotesListView()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    IntroView()
}
