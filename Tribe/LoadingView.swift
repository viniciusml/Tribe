//
//  LoadingView.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import SwiftUI

struct LoadingView: View {
    
    private let stillLoading: Bool
    
    init(stillLoading: Bool) {
        self.stillLoading = stillLoading
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ProgressView("Loading...")
                .foregroundColor(.init(uiColor: .label))
                .progressViewStyle(CircularProgressViewStyle(tint: .init(uiColor: .secondaryLabel)))
                .scaleEffect(2)
                .padding()
            
            if stillLoading {
                Text("Waiting for internet connection")
                    .font(.headline)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    LoadingView(stillLoading: false)
}
