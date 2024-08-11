//
//  ImageDownloadFeature.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import Foundation

enum ImageDownload {
    
    enum Action {
        case downloadImage
    }
    
    enum Update {
        case new(viewModel: ViewModel)
    }
    
    struct ViewModel {
        
        enum State {
            case loading
            case loaded(Data)
            case failed
        }
        
        let state: State
        
        init(state: State) {
            self.state = state
        }
    }
    
    enum Constant {
        static let downloadTimeout: TimeInterval = 2.0
        static let imageURL: URL = URL(string: "https://images.amcnetworks.com/amc.com/wp-content/uploads/2015/04/cast_bb_700x1000_walter-white-lg.jpg")!
    }
}
