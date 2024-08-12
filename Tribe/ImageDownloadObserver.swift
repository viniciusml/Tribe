//
//  ImageDownloadObserver.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import Foundation

final class ImageDownloadObserver: ObservableObject {
    
    private(set) var viewModel: ImageDownload.ViewModel = .init(state: .loading)
    private let presenter: ImageDownloadPresenting
    
    init(presenter: ImageDownloadPresenting) {
        self.presenter = presenter
    }
    
    func perform(_ action: ImageDownload.Action) async {
        await presenter.perform(action)
    }
}

extension ImageDownloadObserver: ImageDownloadScene {
    
    func perform(_ update: ImageDownload.Update) {
        switch update {
        case .new(viewModel: let viewModel):
            self.viewModel = viewModel
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
    }
}
