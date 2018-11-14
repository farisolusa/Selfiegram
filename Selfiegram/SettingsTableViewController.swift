//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/14/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import UIKit

enum SettingsKey: String {
    case saveLocation
}
class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var locationSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
    }

    @IBAction func locationSwitchToggled(_ sender: Any) {
        UserDefaults.standard.set(locationSwitch.isOn, forKey: SettingsKey.saveLocation.rawValue)
    }

    

}
