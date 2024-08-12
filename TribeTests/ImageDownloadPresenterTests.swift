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
        let (sut, scene) = makeSUT()
        
        await sut.perform(.downloadImage)
        
        XCTAssertEqual(scene.log, [
            .performUpdate(.new(viewModel: .init(state: .stillLoading)))
        ])
        XCTAssertEqual(networkOperationPerformerSpy.log, [.perform(2.0)])
    }
}

private extension ImageDownloadPresenterTests {
    
    private func makeSUT() -> (presenter: ImageDownloadPresenter, scene: ImageDownloadSceneSpy) {
        let scene = ImageDownloadSceneSpy()
        let sut = ImageDownloadPresenter(dependencyContainer: makeDependencyContainer())
        
        sut.scene = scene
        return (sut, scene)
    }
    
    private func makeDependencyContainer() -> ImageDownloadPresenter.DependencyContainer {
        .init(visualInspectionTimeout: 0,
              waitingForConnectivityTimeout: 0,
        networkOperationPerformer: networkOperationPerformerSpy)
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
        
        func performNetworkOperation(using closure: @escaping () -> Void, withinSeconds timeoutDuration: TimeInterval) -> CancellableTask {
            log.append(.performNetworkOperation(timeoutDuration))
            return FakeTask()
        }
        
        func perform(withinSeconds timeoutDuration: TimeInterval, operation: @escaping () async -> ()) async -> CancellableTask {
            log.append(.perform(timeoutDuration))
            return FakeTask()
        }
    }
}
