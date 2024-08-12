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
    
    struct DependencyContainer {
        let visualInspectionTimeout: TimeInterval
        let waitingForConnectivityTimeout: TimeInterval
        let networkOperationPerformer: NetworkOperationPerforming
        
        init(visualInspectionTimeout: TimeInterval = ImageDownload.Constant.visualInspectionTimeout,
             waitingForConnectivityTimeout: TimeInterval = ImageDownload.Constant.waitingForConnectivityTimeout,
             networkOperationPerformer: NetworkOperationPerforming = NetworkOperationPerformer()) {
            self.visualInspectionTimeout = visualInspectionTimeout
            self.waitingForConnectivityTimeout = waitingForConnectivityTimeout
            self.networkOperationPerformer = networkOperationPerformer
        }
    }
    
    private let dependencyContainer: DependencyContainer
    
    init(dependencyContainer: DependencyContainer = .init()) {
        self.dependencyContainer = dependencyContainer
    }
    
    func perform(_ action: ImageDownload.Action) async {
        switch action {
        case .downloadImage:
            await downloadImage()
        }
    }
    
    private func downloadImage() async {
        await informWaitingForConnectivity(timeout: dependencyContainer.visualInspectionTimeout)
        await dependencyContainer.networkOperationPerformer
            .perform(withinSeconds: ImageDownload.Constant.downloadTimeout) { [weak self] in
                await self?.attemptToDownloadImage()
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
        let waitingForConnectivityTimeout = dependencyContainer.waitingForConnectivityTimeout
        try? await Task.sleep(for: .seconds(waitingForConnectivityTimeout))
        scene?.perform(.new(viewModel: .init(state: .stillLoading)))
        try? await waitForVisualInspection(timeout: timeout - waitingForConnectivityTimeout)
    }
    
    /// This method allows for the loading screen to be shown for 5 seconds to allow for enough time to visually test the behavior.
    private func waitForVisualInspection(timeout: TimeInterval) async throws {
        try await Task.sleep(for: .seconds(timeout))
    }
}
