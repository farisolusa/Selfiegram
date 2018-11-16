//
//  SelfieListViewController.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/7/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import UIKit
import CoreLocation

class SelfieListViewController: UITableViewController {

    var detailViewController: SelfieDetailViewController? = nil
    var selfies: [Selfie] = []

    let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    // stores the last location that CoreLocation was able to determine
    var lastLocation: CLLocation?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load list of selfies from the selfie store
        
        do {
            selfies = try SelfieStore.shared.listSelfies().sorted(by: { $0.created > $1.created })
        } catch {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1]
                as? UINavigationController)?.topViewController
                as? SelfieDetailViewController
        }
        
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
        
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    @objc func createNewSelfie() {
        
        // Clear the last location, so that this next image doesn't end up with an outOfDate location
        lastLocation = nil
        
        let shouldGetLocation = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        
        if shouldGetLocation {
            // Handle our authorization status
            switch CLLocationManager.authorizationStatus() {
            case .denied, .restricted:
                // We either don't the permission, or the user is not permitted to use location services at all. Give up at this point.
                return
            case .notDetermined:
                // We don't know if we have the permission or not. Ask for it.
                locationManager.requestWhenInUseAuthorization()
            default:
                // We have permission. Nothing to do here.
                break
            }
            
            locationManager.requestLocation()
        }
        
        /*
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        */
        
        guard let navigation = self.storyboard?.instantiateViewController(withIdentifier: "CaptureScene") as? UINavigationController,
        let capture = navigation.viewControllers.first as? CaptureViewController else {
            fatalError("Failed to create the capture view controllers")
        }
        
        capture.complition = {(image: UIImage?) in
            if let image = image {
                self.newSelfieTaken(image: image)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        self.present(navigation, animated: true, completion: nil)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selfie = selfies[indexPath.row]
                if let controller = (segue.destination as? UINavigationController)?.topViewController as? SelfieDetailViewController {
                    controller.selfie = selfie
                    controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }


    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let selfie = selfies[indexPath.row]
        cell.textLabel?.text = selfie.title
        
        // Setup its time ago sublabel
        if let interval = timeIntervalFormatter.string(from: selfie.created, to: Date()) {
            cell.detailTextLabel?.text = "\(interval) ago"
        } else {
            cell.detailTextLabel?.text = nil
        }
        cell.imageView?.image = selfie.image
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get objet from context array
            let selfieToRemove = selfies[indexPath.row]
            
            // Attempt to delete the selfie
            do {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                selfies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let title = selfieToRemove.title
                showError(message: "Failed to remove: \(title).")
            }
        }
    }
    */
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, indexPath) in
            guard let image = self.selfies[indexPath.row].image else {
                self.showError(message: "Unable to share selfie without an image.")
                return
            }
            
            let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activity, animated: true, completion: nil)
        }
        
        share.backgroundColor = self.view.tintColor
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // Get the object from content array
            let selfieToRemove = self.selfies[indexPath.row]
            
            // Attempt to delete the selfie
            do {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                // Remove it from that array
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                self.showError(message: "Failed to delete \(selfieToRemove.title)")
            }
        }
        return [delete, share]
    }

    /*
    Called after the user has selected a photo
    */
    func newSelfieTaken(image: UIImage) {
        // Create a new image
        let newSelfie = Selfie(title: "New Selfie")
        // Store the image
        newSelfie.image = image
        
        if let location = self.lastLocation {
            newSelfie.position = Selfie.Coordinate(location: location)
        }
        
        // Attempt to save the photo
        do {
            try SelfieStore.shared.save(selfie: newSelfie)
        } catch {
            showError(message: "Can't save photo: \(error)")
            return
        }
        
        // Insert this photo into this view controller's list
        selfies.insert(newSelfie, at: 0)
        
        // Update the tableView to show the new Photo
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }


}

/*
extension SelfieListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            ?? info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                let message = "Could not get a picture from the image picker!"
                showError(message: message)
                return
        }
        
        self.newSelfieTaken(image: image)
        
        // Get rid of the viewController
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
*/

extension SelfieListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: error.localizedDescription)
    }
}
