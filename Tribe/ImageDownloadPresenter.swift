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
            performAfter(seconds: 5.0) { [weak self] in
                self?.downloadImage()
            }
        }
    }
    
    private func downloadImage() {
        let timerTask = Task {
            try? await informWaitingForConnectivity(timeout: 0.5)
        }
        Task { @MainActor in
            await NetworkOperationPerformer()
                .perform(withinSeconds: ImageDownload.Constant.downloadTimeout) { [weak self] in
                    await self?.attemptToDownloadImage()
                }
            timerTask.cancel()
        }
    }
    
    private func attemptToDownloadImage() async {
        do {
            let result = try await URLSession.shared.data(for: URLRequest(url: ImageDownload.Constant.imageURL))
            
            scene?.perform(.new(viewModel: .init(state: .loaded(result.0))))
        } catch {
            
            scene?.perform(.new(viewModel: .init(state: .failed)))
        }
    }
    
    private func informWaitingForConnectivity(timeout: TimeInterval) async throws {
        try await Task.sleep(for: .seconds(timeout))
        scene?.perform(.new(viewModel: .init(state: .stillLoading)))
    }
    
    /// This method allows for the loading screen to be shown for 5 seconds to allow for enough time to visually test the behavior.
    private func performAfter(seconds: TimeInterval, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
            action()
        })
    }
}
