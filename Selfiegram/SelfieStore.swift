//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/7/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import Foundation
import UIKit.UIImage
import CoreLocation.CLLocation

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
    
    struct Coordinate: Codable, Equatable {
        var latitude: Double
        var longitude: Double
        
        // Required equality method to conform to the Equatable protocol
        public static func == (lhs: Selfie.Coordinate,
                               rhs: Selfie.Coordinate) -> Bool {
            return lhs.latitude == lhs.latitude &&
                rhs.longitude == rhs.longitude
        }
        
        var loaction: CLLocation {
            get {
                return CLLocation(latitude: self.latitude,
                                  longitude: self.longitude)
            } set {
                self.latitude = newValue.coordinate.latitude
                self.longitude = newValue.coordinate.longitude
            }
        }
        
        init(location: CLLocation) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
}

enum SelfieStoreError: Error {
    case cannotSaveImage(UIImage?)
}

final class SelfieStore {
    static let shared = SelfieStore()
    
    /*
     “Whenever a selfie’s image is requested the store will use the id property as the key and look for the image in the cache”
    */
    private var imageCache: [UUID: UIImage] = [:]
    
    var documentsFolder: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }
    
    /*
     “will return the image associated with a particular selfie’s id, or nil if it can’t find one.”
    */
    func getImage(id: UUID) -> UIImage? {
        if let image = imageCache[id] {
            return image
        }
        let imageURL = documentsFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        //print("Document Directory: \(imageURL)")
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return nil
        }
        
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        
        imageCache[id] = image
        return image
    }
    
    /*
     “will save the image to disk using the id passed in to associate it back with a selfie.”
    */
    func setImage(id: UUID, image: UIImage?) throws {
        //Figure out where the file would end up
        let fileName = "\(id.uuidString)-image.jpg"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        if let image = image {
            // Attempt to convert the image into JPEG data
            // guard let data = UIImageJPEGRepresentation(image, 0.9) // Swift 4
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                // Throws an error if failed
                throw SelfieStoreError.cannotSaveImage(image)
            }
            // Attempt to write the data out
            try data.write(to: destinationURL)
        } else {
            // The image is nil, indicating that we want to remove the image
            // Attempt to perform the deletion
            try FileManager.default.removeItem(at: destinationURL)
        }
        // Cache this image in the momory. (If image is nil, this has the effect of removing the entry form the cache dictionary)
        imageCache[id] = image
    }
    
    /*
     “will return an array of every selfie in the store.”
    */
    func listSelfies() throws -> [Selfie] {
        // Get the list of file in the directory
        let contents = try FileManager.default.contentsOfDirectory(at: self.documentsFolder, includingPropertiesForKeys: nil)
        // Get all the file with extension "json"
        // Load them as data, and decode them from JSON
        return try contents.filter { $0.pathExtension == "json" }
            .map { try Data(contentsOf: $0) }
            .map { try JSONDecoder().decode(Selfie.self, from: $0)}
    }
    
    /*
     “will delete the selfie and its associated image. It does this by calling the other delete function and using the selfie’s id.”
    */
    func delete(selfie: Selfie) throws {
        // Takes "id" from the selfie and gives it to the other version of delete func.
        try delete(id: selfie.id)
    }
    
    /*
     “will delete the selfie (and its associated image) that matches the id parameter.”
    */
    func delete(id: UUID) throws {
        let selfieDataFileName = "\(id.uuidString).json"
        let imageFileName = "\(id.uuidString)-image.jpg"
        
        let selfieDataURL = self.documentsFolder.appendingPathComponent(selfieDataFileName)
        let imageURL = self.documentsFolder.appendingPathComponent(imageFileName)
        
        // Remove the two files if they exist
        if FileManager.default.fileExists(atPath: selfieDataURL.path) {
            try FileManager.default.removeItem(at: selfieDataURL)
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        // Wipe the image fromt he cache if it's there
        imageCache[id] = nil
    }
    
    /*
     “will load the selfie that matches the id from disk.”
    */
    func load(id: UUID) -> Selfie? {
        let dataFileName = "\(id.uuidString).json"
        let dataURL = self.documentsFolder.appendingPathComponent(dataFileName)
        
        /*
        Attempt to load data in this file and then attempt to convert the data into a Photo and then return it.
         Return nil if any of these steps fail
        */
        if let data = try? Data(contentsOf: dataURL),
            let selfie = try? JSONDecoder().decode(Selfie.self, from: data) {
            return selfie
        } else {
            return nil
        }
    }
    
    /*
     “will save the passed-in selfie to disk.”
    */
    func save(selfie: Selfie) throws {
        let selfieData = try JSONEncoder().encode(selfie)
        
        let fileName = "\(selfie.id.uuidString).json"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        try selfieData.write(to: destinationURL)
    }
}
