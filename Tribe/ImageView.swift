//
//  ImageView.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import SwiftUI

struct ImageView: View {
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 10)
                .padding()
            
            Text("This is the loaded image")
                .font(.headline)
                .padding(.top, 10)
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    ImageView()
}
