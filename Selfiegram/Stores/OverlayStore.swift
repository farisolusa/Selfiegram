//
//  OverlayStore.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/17/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import Foundation

struct OverlayInformation: Codable {
    let icon: String
    let leftImage: String
    let rightImage: String
}

enum OverlayManagerError: Error {
    case noDataLoaded
    case cannotParseData(underlyingError: Error)
}

final class OverlayManager {
    static let shared = OverlayManager()
    typealias OverlayList = [OverlayInformation]
    private var overlayInfo: OverlayList
    
    static let downloadURLBase = URL(
        string: "https://raw.githubusercontent.com/thesecretelab/learning-swift-3rd-ed/master/Data/")!
    
    static let overlayListURL = URL(
        string: "overlays.json",
        relativeTo: OverlayManager.downloadURLBase)!
    
    static var cacheDirectoryURL: URL {
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Cache directory not found! This should not happen!")
        }
        
    }
    
    
}
