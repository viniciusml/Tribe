//
//  ContentView.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                LoadingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
