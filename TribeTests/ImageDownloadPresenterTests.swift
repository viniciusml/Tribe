//
//  ImageDownloadPresenterTests.swift
//  TribeTests
//
//  Created by Vinicius Leal on 11/08/2024.
//

@testable import Tribe
import Lotus
import XCTest

final class ImageDownloadPresenterTests: XCTestCase {
    
    private var networkOperationPerformerSpy: NetworkOperationPerformerSpy!
    
    override func setUp() {
        super.setUp()
        
        networkOperationPerformerSpy = NetworkOperationPerformerSpy()
    }
    
    override func tearDown() {
        networkOperationPerformerSpy = nil
        
        super.tearDown()
    }
    
    func test_downloadImage_withNoNetworkCompletion_updatesToStillLoading() async {
        let imageDownloadAction = ImageDownloadActionStub(stubbed: .failure(NSError(domain: "any error", code: -2)))
        networkOperationPerformerSpy.shouldWaitForOperation = false
        let (sut, scene) = makeSUT(imageDownloadAction: imageDownloadAction)
        
        await sut.perform(.downloadImage)
        
        XCTAssertEqual(scene.log, [
            .performUpdate(.new(viewModel: .init(state: .stillLoading)))
        ])
        XCTAssertEqual(networkOperationPerformerSpy.log, [.perform(2.0)])
    }
    
    func test_downloadImage_withFailedNetworkCompletion_updatesWithFailure() async {
        let imageDownloadAction = ImageDownloadActionStub(stubbed: .failure(NSError(domain: "any error", code: -2)))
        let (sut, scene) = makeSUT(imageDownloadAction: imageDownloadAction)
        
        await sut.perform(.downloadImage)
        
        XCTAssertEqual(scene.log, [
            .performUpdate(.new(viewModel: .init(state: .stillLoading))),
            .performUpdate(.new(viewModel: .init(state: .failed)))
        ])
        XCTAssertEqual(networkOperationPerformerSpy.log, [.perform(2.0)])
    }
}

private extension ImageDownloadPresenterTests {
    
    private func makeSUT(imageDownloadAction: ImageDownloadActionStub) -> (presenter: ImageDownloadPresenter, scene: ImageDownloadSceneSpy) {
        let scene = ImageDownloadSceneSpy()
        let sut = ImageDownloadPresenter(dependencyContainer: makeDependencyContainer(imageDownloadAction: imageDownloadAction))
        
        sut.scene = scene
        return (sut, scene)
    }
    
    private func makeDependencyContainer(imageDownloadAction: ImageDownloadActionStub) -> ImageDownloadPresenter.DependencyContainer {
        .init(visualInspectionTimeout: 0,
              waitingForConnectivityTimeout: 0,
        networkOperationPerformer: networkOperationPerformerSpy,
        imageDownloadAction: imageDownloadAction.data(for:delegate:))
    }
    
    final class ImageDownloadSceneSpy: ImageDownloadScene {
        enum MethodCall: Equatable {
            case performUpdate(ImageDownload.Update)
        }
        
        private(set) var log: [MethodCall] = []
        
        func perform(_ update: ImageDownload.Update) {
            log.append(.performUpdate(update))
        }
    }
    
    final class NetworkOperationPerformerSpy: NetworkOperationPerforming {
        
        enum MethodCall: Equatable {
            case performNetworkOperation(TimeInterval)
            case perform(TimeInterval)
        }
        
        struct FakeTask: CancellableTask {
            var operation: (() -> Void)?
            func cancel() {}
        }
        
        private(set) var log: [MethodCall] = []
        var shouldWaitForOperation: Bool = true
        
        func performNetworkOperation(using closure: @escaping () -> Void, withinSeconds timeoutDuration: TimeInterval) -> CancellableTask {
            log.append(.performNetworkOperation(timeoutDuration))
            return FakeTask()
        }
        
        func perform(withinSeconds timeoutDuration: TimeInterval, operation: @escaping () async -> ()) async -> CancellableTask {
            log.append(.perform(timeoutDuration))
            
            if shouldWaitForOperation {
                await operation()
            }
            
            return FakeTask()
        }
    }
    
    final class ImageDownloadActionStub {
        
        private let stubbed: Result<(Data, URLResponse), Error>
        
        init(stubbed: Result<(Data, URLResponse), Error>) {
            self.stubbed = stubbed
        }
        
        func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
            switch stubbed {
            case .success(let success):
                return success
            case .failure(let failure):
                throw failure
            }
        }
    }
}
