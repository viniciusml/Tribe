//
//  ContentView.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var observer: ImageDownloadObserver
    
    init(observer: ImageDownloadObserver) {
        self.observer = observer
    }
    
    var body: some View {
        VStack {
            switch observer.viewModel.state {
            case .failed:
                DownloadFailedView()
            case .stillLoading:
                LoadingView(stillLoading: true)
            case .loading:
                LoadingView(stillLoading: false)
            case .loaded(let data):
                if let image = UIImage(data: data) {
                    ImageView(image: image)
                } else {
                    DownloadFailedView()
                }
            }
        }.onAppear {
            Task { @MainActor in
                await observer.perform(.downloadImage)
            }
        }
    }
}
