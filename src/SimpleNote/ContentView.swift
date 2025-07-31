//
//  ContentView.swift
//  SimpleNote
//
//  Created by Ali M.Sh on 4/19/1404 AP.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        if isAuthenticated {
            // Main app navigation stack
            NotesListView()
        } else {
            // Authentication navigation stack
            IntroView()
        }
    }
}

#Preview {
    ContentView()
}
