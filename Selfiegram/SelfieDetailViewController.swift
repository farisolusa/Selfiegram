//
//  SelfieDetailViewController.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/7/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import UIKit
import MapKit

class SelfieDetailViewController: UIViewController {

    @IBOutlet weak var selfieNameField: UITextField!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var mapview: MKMapView!
    
    
    var selfie: Selfie? {
        didSet {
            configureView()
        }
    }
    
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()

    func configureView() {
        guard let selfie = selfie else {
            return
        }
        guard let   selfieNameField = selfieNameField,
              let   selfieImageView = selfieImageView,
              let   dateCreatedLabel = dateCreatedLabel
            else {
                return
        }
        
        selfieNameField.text = selfie.title
        dateCreatedLabel.text = dateFormatter.string(from: selfie.created)
        selfieImageView.image = selfie.image
        
        // If selfie has embedded location, then show the Map
        if let position = selfie.position {
            self.mapview.setCenter(position.loaction.coordinate, animated: false)
            mapview.isHidden = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    

    @IBAction func doneButtonTapped(_ sender: Any) { // Added on UITextField "Primary Action Triggered"
        selfieNameField.resignFirstResponder()
        
        guard let selfie = selfie else {
            return
        }
        
        guard let text = self.selfieNameField.text else {
            return
        }
        
        selfie.title = text
        
        do {
            try SelfieStore.shared.save(selfie: selfie)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func expandMap(_ sender: Any) {
        if let coordinate = self.selfie?.position?.loaction {
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate.coordinate),
                MKLaunchOptionsMapTypeKey: NSNumber(value: MKMapType.mutedStandard.rawValue)
            ]
            
            let placemark = MKPlacemark(coordinate: coordinate.coordinate, addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            item.name = selfie?.title
            
            item.openInMaps(launchOptions: options)
        }
    }
    
    @IBAction func sharedSelfie(_ sender: Any) {
        guard let image = self.selfie?.image else {
            // Pop up an alert dialog letting us know it has failed
            let alert = UIAlertController(title: "Error", message: "Unable to share selfie without on image", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
    
}

