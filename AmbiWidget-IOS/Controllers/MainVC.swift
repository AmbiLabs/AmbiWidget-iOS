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
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Get the refresh token
		firstly {
			TokenManager.getRefreshToken()
		}.done { token in
			// Do nothing...
		}.catch { error in
			// Show auth view page
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "auth") as! AuthVC
			self.present(vc, animated: true, completion: nil)
		}
		
		// Debugging
		DeviceManager.getDeviceList().done { arrayOfDevices in
			print("Device List: ")
			for device in arrayOfDevices {
				print(device)
			}
		}.catch { error in
			print ("\(String(describing: self)) Error: \(error)")
		}
	}
}
