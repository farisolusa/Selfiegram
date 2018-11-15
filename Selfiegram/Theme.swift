//
//  Theme.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/15/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    static func apply() {
        guard let headerFont = UIFont(familyName: "Lobster", size: UIFont.systemFontSize * 2) else {
            NSLog("Failed to load header font")
            return
        }
        
        guard let primaryFont = UIFont(familyName: "Quicksand") else {
            NSLog("Failed to lead application foot")
            return
        }
        
        let tintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        UIApplication.shared.delegate?.window??.tintColor = tintColor
        
        let navBarLabel = UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        let barButton = UIBarButtonItem.appearance()
        let barButtonLabel = UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])
        let navBar = UINavigationBar.appearance()
        let label = UILabel.appearance()
        
        navBar.titleTextAttributes = [.font: headerFont]
        navBarLabel.font = primaryFont
        
        label.font = primaryFont
        
        barButton.setTitleTextAttributes([.font: primaryFont], for: .normal)
        barButton.setTitleTextAttributes([.font: primaryFont], for: .highlighted)
        
        barButtonLabel.font = primaryFont
    }
}

extension UIFont {
    convenience init?(familyName: String,
                      size: CGFloat = UIFont.systemFontSize,
                      variantName: String? = nil) {
        guard let name = UIFont.familyNames
            .filter({ $0.contains(familyName) })
            .flatMap({ UIFont.fontNames(forFamilyName: $0)} ) // flatMap is deprecated
            .filter({ variantName != nil ?
                $0.contains(variantName!): true})
            .first else {
            return nil
        }
        
        self.init(name: name, size: size)
    }
}
