//
//  SelfieStoreTests.swift
//  SelfiegramTests
//
//  Created by Anil Prasad on 11/8/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import XCTest
@testable import Selfiegram
import UIKit

class SelfieStoreTests: XCTestCase {

    func createImage(text: String) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        defer {
            UIGraphicsEndImageContext()
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.font = UIFont.systemFont(ofSize: 50)
        label.text = text
        label.drawHierarchy(in: label.frame, afterScreenUpdates: true)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func testCreatingSelfie() {
        let selfieTitle = "Creation Test Selfie"
        let newSelfie = Selfie(title: selfieTitle)
        
        try? SelfieStore.shared.save(selfie: newSelfie)
        
        let allSelfies = try! SelfieStore.shared.listSelfies()
        
        guard allSelfies.first(where: {$0.id == newSelfie.id}) != nil else {
            XCTFail("Selfies list should contain the one we just created.")
            return
        }
        
        XCTAssertEqual(selfieTitle, newSelfie.title)
    }
    
    func testSavingImage() throws {
        // Arrange
        let newSelfie = Selfie(title: "Selfie with image test")
        
        // Act
        newSelfie.image = createImage(text: "🤪")
        try SelfieStore.shared.save(selfie: newSelfie)
        
        // Assert
        let loadedImage = SelfieStore.shared.getImage(id: newSelfie.id)
        XCTAssertNotNil(loadedImage, "The image should be loaded")
    }

    func testLoadingSelfie() throws {
        // Arrange
        let selfieTitle = "Test loading selfie"
        let newSelfie = Selfie(title: selfieTitle)
        
        try SelfieStore.shared.save(selfie: newSelfie)
        let id = newSelfie.id
        
        // Act
        let loadedSelfie = SelfieStore.shared.load(id: id)
        
        // Assert
        XCTAssertNotNil(loadedSelfie, "The selfie should be loaded")
        XCTAssertEqual(loadedSelfie?.id, newSelfie.id, "The loaded selfie should have the same ID")
        XCTAssertEqual(loadedSelfie?.created, newSelfie.created, "The loaded selfie should have the same creation date")
        XCTAssertEqual(loadedSelfie?.title, newSelfie.title, "The loaded selfie should have the same title")
    }
    
    func testDeletionSelfie() throws {
        // Arrange
        let newSelfie = Selfie(title: "Test deleting a selfie")
        try SelfieStore.shared.save(selfie: newSelfie)
        let id = newSelfie.id
        
        // Act
        let allSelfies = try SelfieStore.shared.listSelfies()
        try SelfieStore.shared.delete(id: id)
        let selfieList = try SelfieStore.shared.listSelfies()
        let loadedSelfie = SelfieStore.shared.load(id: id)
        
        // Assert
        XCTAssertEqual(allSelfies.count - 1, selfieList.count, "There should be one less selfie after deletion")
        XCTAssertNil(loadedSelfie, "Deleted selfie should be nil")
    }
}
