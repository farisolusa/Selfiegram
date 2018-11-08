//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/7/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import Foundation
import UIKit.UIImage

class Selfie: Codable {
    let created: Date
    let id: UUID
    var title = "New Selfie!"
    
    var image: UIImage? {
        get {
            return SelfieStore.shared.getImage(id: self.id)
        }
        set {
            try? SelfieStore.shared.setImage(id: self.id, image: newValue)
        }
    }
    
    init(title: String) {
        self.title = title
        self.created = Date()
        self.id = UUID()
    }
}

enum SelfieStoreError: Error {
    case cannotSaveImage(UIImage?)
}

final class SelfieStore {
    static let shared = SelfieStore()
    
    /*
     “will return the image associated with a particular selfie’s id, or nil if it can’t find one.”
    */
    func getImage(id: UUID) -> UIImage? {
        return nil
    }
    
    /*
     “will save the image to disk using the id passed in to associate it back with a selfie.”
    */
    func setImage(id: UUID, image: UIImage?) throws {
        throw SelfieStoreError.cannotSaveImage(image)
    }
    
    /*
     “will return an array of every selfie in the store.”
    */
    func listSelfies() throws -> [Selfie] {
        return []
    }
    
    /*
     “will delete the selfie and its associated image. It does this by calling the other delete function and using the selfie’s id.”
    */
    func delete(selfie: Selfie) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    /*
     “will delete the selfie (and its associated image) that matches the id parameter.”
    */
    func delete(id: UUID) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    /*
     “will load the selfie that matches the id from disk.”
    */
    func load(id: UUID) -> Selfie? {
        return nil
    }
    
    /*
     “will save the passed-in selfie to disk.”
    */
    func save(selfie: Selfie) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
}
