//
//  SelfieListViewController.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/7/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import UIKit

class SelfieListViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var selfies: [Selfie] = []

    let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
    

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
                as? DetailViewController
        }
        
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
    }
    
    @objc func createNewSelfie() {
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

   


}

extension SelfieListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
