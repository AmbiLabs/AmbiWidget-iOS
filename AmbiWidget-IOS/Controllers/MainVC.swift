//
//  MainVC.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 30/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit
import PromiseKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Add listener for when application is opened
		NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
	
	@objc func viewDidBecomeActive() {
		// Check if refresh token is set
		TokenManager.loadTokenFromUserDefaultsAsPromise(with: .RefreshToken)
		.catch { error in
			// Show auth view page
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "auth") as! AuthVC
			self.present(vc, animated: true, completion: nil)
		}
	}
	
	// Open Application Settings
	@IBAction func settingsButton(_ sender: UIBarButtonItem) {
		UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: nil)
	}
}
