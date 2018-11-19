//
//  DataLoadingTests.swift
//  SelfiegramTests
//
//  Created by Anil Prasad on 11/20/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import XCTest
@testable import Selfiegram

class DataLoadingTests: XCTestCase {

    override func setUp() {
        // Remove all cached data
        let cachedURL = OverlayManager.cacheDirectoryURL
        
        guard let contents = try? FileManager.default.contentsOfDirectory(at: cachedURL, includingPropertiesForKeys: nil, options: []) else {
            XCTFail("Failed to list contents of directory \(cachedURL)")
            return
        }
        
        var complete = true
        for file in contents {
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Test setup: Failed to remove item \(file); \(error)")
                complete = false
            }
        }
        if !complete {
            XCTFail("Failed to delete contents of cache")
        }
    }
    
    func testNoOverlaysAvailable() {
        // Arrange
        // Nothing to arrange here: our start condition is that there is no cached data
        
        // Act
        let availableOverlays = OverlayManager.shared.availableOverlays()
        
        // Assert
        XCTAssertEqual(availableOverlays.count, 0)
    }
    
    func testGettingOverlayInfo() {
        // Arrange
        let expectation = self.expectation(description: "Done downloading")
        
        // Act
        var loadedInfo: OverlayManager.OverlayList?
        var loadedError: Error?
        
        OverlayManager.shared.refreshOverlays { (info, error) in
            loadedInfo = info
            loadedError = error
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        // Assert
        XCTAssertNotNil(loadedInfo)
        XCTAssertNil(loadedError)
    }
    
    // The Overlay manager can download overlay assets, making them available for use
    func testDownloadingOverlays() {
        // Arrange
        let loadingComplete = self.expectation(description: "Download done")
        var availableOverlays: [Overlay] = []
        
        // Act
        OverlayManager.shared.loadOverlayAssets(refresh: true) {
            availableOverlays = OverlayManager.shared.availableOverlays()
            loadingComplete.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
        
        // Assert
        XCTAssertNotEqual(availableOverlays.count, 0)
    }

    func testDownloadedOverlaysAreCached() {
        // Arrange
        let downloadingOverlayManager = OverlayManager()
        let downloadExpectation = self.expectation(description: "Data downloaded")
        
        // Start downloading
        downloadingOverlayManager.loadOverlayAssets(refresh: true) {
            downloadExpectation.fulfill()
        }
        
        // Wait for download to finish
        waitForExpectations(timeout: 10.0, handler: nil)
        
        // Act
        // Simulate the overlay manager starting up by initializing a new one; it will access the same files that were downloaded earlier
        let cacheTestOverlayManager = OverlayManager()
        
        // Assert
        // This overlay manager should see the cached data
        XCTAssertNotEqual(cacheTestOverlayManager.availableOverlays().count, 0)
        XCTAssertEqual(cacheTestOverlayManager.availableOverlays().count, downloadingOverlayManager.availableOverlays().count)
    }
    
    override func tearDown() {
    }
}
