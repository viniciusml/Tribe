//
//  ImageDownloadPresenter.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import Foundation
import Lotus

final class ImageDownloadPresenter {
    
    weak var scene: ImageDownloadScene?
    
    func perform(_ action: ImageDownload.Action) {
        switch action {
        case .downloadImage:
            downloadImage()
        }
    }
    
    private func downloadImage() {
        Task { @MainActor in
            await NetworkOperationPerformer()
                .perform(withinSeconds: ImageDownload.Constant.downloadTimeout) { [weak self] in
                    do {
                        let result = try await URLSession.shared.data(for: URLRequest(url: ImageDownload.Constant.imageURL))
                        
                        self?.scene?.perform(.new(viewModel: .init(state: .loaded(result.0))))
                    } catch {
                        
                        self?.scene?.perform(.new(viewModel: .init(state: .failed)))
                    }
                }
        }
    }
}
