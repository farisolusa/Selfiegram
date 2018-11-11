//
//  SelfieDetailViewController.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/7/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import UIKit

class SelfieDetailViewController: UIViewController {

    @IBOutlet weak var selfieNameField: UITextField!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!
    
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
    


}

