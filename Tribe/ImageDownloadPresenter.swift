//
//  ImageDownloadPresenter.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import Foundation
import Lotus

protocol ImageDownloadPresenting {
    func perform(_ action: ImageDownload.Action) async
}

final class ImageDownloadPresenter: ImageDownloadPresenting {
    
    weak var scene: ImageDownloadScene?
    
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
            let result = try await dependencyContainer.imageDownloadAction(URLRequest(url: ImageDownload.Constant.imageURL), nil)
            
            await performUpdateOnMainThread(.loaded(result.0))
        } catch {
            
            await performUpdateOnMainThread(.failed)
        }
    }
    
    @MainActor
    private func performUpdateOnMainThread(_ state: ImageDownload.ViewModel.State) {
        scene?.perform(.new(viewModel: .init(state: state)))
    }
    
    private func informWaitingForConnectivity(timeout: TimeInterval) async {
        let waitingForConnectivityTimeout = dependencyContainer.waitingForConnectivityTimeout
        try? await Task.sleep(for: .seconds(waitingForConnectivityTimeout))
        await performUpdateOnMainThread(.stillLoading)
        try? await waitForVisualInspection(timeout: timeout - waitingForConnectivityTimeout)
    }
    
    /// This method allows for the loading screen to be shown for 5 seconds to allow for enough time to visually test the behavior.
    private func waitForVisualInspection(timeout: TimeInterval) async throws {
        try await Task.sleep(for: .seconds(timeout))
    }
}

extension ImageDownloadPresenter {
    
    /// This is a workaround to inject dependencies needed, in order to properly unit test the expected behaviour of the presenter.
    /// In an ideal world, these would be abstract interfaces that could be swapped by test doubles.
    /// The network layer, for instance, would be an `HTTPClient` encapsulating `URLSession`, and the tests would rely on a `URLProtocol` stub.
    /// For the `Task.sleep`, these could be encapsulated as well, making it synchronous in code.
    /// For simplicity, I chose this approach, which still allows me to test the presenter in relative isolation.
    struct DependencyContainer {
        typealias ImageDownloadAction = (URLRequest, (URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
        
        let visualInspectionTimeout: TimeInterval
        let waitingForConnectivityTimeout: TimeInterval
        let networkOperationPerformer: NetworkOperationPerforming
        let imageDownloadAction: ImageDownloadAction
        
        init(visualInspectionTimeout: TimeInterval = ImageDownload.Constant.visualInspectionTimeout,
             waitingForConnectivityTimeout: TimeInterval = ImageDownload.Constant.waitingForConnectivityTimeout,
             networkOperationPerformer: NetworkOperationPerforming = NetworkOperationPerformer(),
             imageDownloadAction: @escaping ImageDownloadAction = URLSession.shared.data) {
            self.visualInspectionTimeout = visualInspectionTimeout
            self.waitingForConnectivityTimeout = waitingForConnectivityTimeout
            self.networkOperationPerformer = networkOperationPerformer
            self.imageDownloadAction = imageDownloadAction
        }
    }
}
