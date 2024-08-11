//
//  DownloadFailedView.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import SwiftUI

struct DownloadFailedView: View {
    var body: some View {
        VStack {
            Text("Failed to download image.")
                .font(.title3)
                .foregroundColor(.red)
                .padding()
            
            Text("Please check your internet connection and try again.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    DownloadFailedView()
}
