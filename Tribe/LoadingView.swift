//
//  LoadingView.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        VStack {
            Spacer()
            
            ProgressView("Loading...")
                .foregroundColor(.init(uiColor: .label))
                .progressViewStyle(CircularProgressViewStyle(tint: .init(uiColor: .secondaryLabel)))
                .scaleEffect(2)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    LoadingView()
}
