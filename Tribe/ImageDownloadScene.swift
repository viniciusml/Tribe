//
//  ImageDownloadScene.swift
//  Tribe
//
//  Created by Vinicius Leal on 11/08/2024.
//

import Foundation

protocol ImageDownloadScene: AnyObject {
    var viewModel: ImageDownload.ViewModel { get }
    
    func perform(_ update: ImageDownload.Update)
}
