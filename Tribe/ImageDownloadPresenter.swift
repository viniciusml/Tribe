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
            await informWaitingForConnectivity(timeout: ImageDownload.Constant.visualInspectionTimeout)
            await NetworkOperationPerformer()
                .perform(withinSeconds: ImageDownload.Constant.downloadTimeout) { [weak self] in
                    await self?.attemptToDownloadImage()
                }
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
    
    private func informWaitingForConnectivity(timeout: TimeInterval) async {
        try? await Task.sleep(for: .seconds(ImageDownload.Constant.waitingForConnectivityTimeout))
        scene?.perform(.new(viewModel: .init(state: .stillLoading)))
        try? await waitForVisualInspection(timeout: timeout - ImageDownload.Constant.waitingForConnectivityTimeout)
    }
    
    /// This method allows for the loading screen to be shown for 5 seconds to allow for enough time to visually test the behavior.
    private func waitForVisualInspection(timeout: TimeInterval) async throws {
        try await Task.sleep(for: .seconds(timeout))
    }
}
