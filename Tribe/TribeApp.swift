//
//  TribeApp.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import SwiftUI

@main
struct TribeApp: App {
    var body: some Scene {
        
        let imageDownloadPresenter = ImageDownloadPresenter()
        lazy var imageDownloadObserver: ImageDownloadObserver = {
            let observer = ImageDownloadObserver(presenter: imageDownloadPresenter)
            imageDownloadPresenter.scene = observer
            return observer
        }()
        
        WindowGroup {
            ContentView(observer: imageDownloadObserver)
        }
    }
}
