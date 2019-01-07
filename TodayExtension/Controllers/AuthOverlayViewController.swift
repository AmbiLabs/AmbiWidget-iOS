//
//  AuthOverlayViewController.swift
//  TodayExtension
//
//  Created by Milan Sosef on 04/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import UIKit

class AuthOverlayViewController: UIViewController {
    
    @IBOutlet weak var authLabel: UILabel!
    
    // Authentication Url & Parameters
    let authoriseURL = "https://api.ambiclimate.com/oauth2/authorize"
    let responseType = "code"

    @IBOutlet weak var authButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add border radius to authorise button
        authButton.layer.cornerRadius = 20
    }
    
    @IBAction func authorise(_ sender: UIButton) {
        
        let myAppUrl = NSURL(string: "widgetcontainingapp://")!
        extensionContext?.open(myAppUrl as URL, completionHandler: { (success) in
            if (!success) {
                // let the user know it failed
                print("Error: something went wrong when tried opening the app...")
            }
        })
    }
    
}
