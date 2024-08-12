//
//  ImageDownloadObserverTests.swift
//  TribeTests
//
//  Created by Vinicius Leal on 12/08/2024.
//

@testable import Tribe
import XCTest

final class ImageDownloadObserverTests: XCTestCase {
    
    func test_performUpdate_updatesViewModel() {
        let sut = ImageDownloadObserver(presenter: ImageDownloadPresenterSpy())
        XCTAssertEqual(sut.viewModel, .init(state: .loading))
        
        sut.perform(.new(viewModel: .init(state: .failed)))
        
        XCTAssertEqual(sut.viewModel, .init(state: .failed))
    }
    
    func test_performAction_callsPresenter() async {
        let presenter = ImageDownloadPresenterSpy()
        let sut = ImageDownloadObserver(presenter: presenter)
        
        await sut.perform(.downloadImage)
        
        XCTAssertEqual(presenter.log, [.perform(.downloadImage)])
    }
}

private extension ImageDownloadObserverTests {
    
    final class ImageDownloadPresenterSpy: ImageDownloadPresenting {
        
        enum MethodCall: Equatable {
            case perform(ImageDownload.Action)
        }
        
        private(set) var log: [MethodCall] = []
        
        func perform(_ action: ImageDownload.Action) async {
            log.append(.perform(action))
        }
    }
}
