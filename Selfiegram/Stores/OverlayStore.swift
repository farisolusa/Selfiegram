//
//  OverlayStore.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/17/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import Foundation
import UIKit.UIImage

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
        return cacheDirectory
    }
    
    static var cacheOverlayListURL: URL {
        return cacheDirectoryURL.appendingPathComponent("overlays.json", isDirectory: false)
    }
    
    // Returns the URL for downloading a named image file
    func urlForAsset(named assetName: String) -> URL? {
        return URL(string: assetName, relativeTo: OverlayManager.downloadURLBase)
    }
    
    // Returns the URL for the cached version of an image file
    func cachedUrlForAsset(named assetNamed: String) -> URL? {
        return URL(string: assetNamed, relativeTo: OverlayManager.cacheDirectoryURL)
    }
    
    init() {
        do {
            let overlayListData = try Data(contentsOf: OverlayManager.cacheOverlayListURL)
            self.overlayInfo = try JSONDecoder().decode(OverlayList.self, from: overlayListData)
        } catch {
            self.overlayInfo = []
        }
    }
    
    func availableOverlays() -> [Overlay] { return [] }
    func refreshOverlays(complition: @escaping (OverlayList?, Error?) -> Void) {}
    func loadOverlayAssets(refresh: Bool = false, complition: @escaping () -> Void) {}
    
}

struct Overlay {
    
    /// The image to show in the list of eyebrow choices to the user
    let previewIcon: UIImage
    
    /// The image to draw on top of the left eyebrow
    let leftImage : UIImage
    /// The image to draw on top of the right eyebrow
    let rightImage : UIImage
    
    /// Failiable initialiser, creates an Overlay given the names of images to use.
    /// The images must be already downloaded and stored in the cache, or this initialiser will return nil.
    /// - parameter info: the information necessary to create the overlay images
    init?(info: OverlayInformation) {
        // Construct the URLs that would point to the cached images.
        guard
            let previewURL = OverlayManager.shared.cachedUrlForAsset(named: info.icon),
            let leftURL = OverlayManager.shared.cachedUrlForAsset(named: info.leftImage),
            let rightURL = OverlayManager.shared.cachedUrlForAsset(named: info.rightImage) else {
                return nil
        }
        
        // Attempt to get the images. If any of them fail, we return nil.
        guard
            let previewImage = UIImage(contentsOfFile: previewURL.path),
            let leftImage = UIImage(contentsOfFile: leftURL.path),
            let rightImage = UIImage(contentsOfFile: rightURL.path) else {
                return nil
        }
        
        // We've got the images, so store them.
        self.previewIcon = previewImage
        self.leftImage = leftImage
        self.rightImage = rightImage
    }
}
