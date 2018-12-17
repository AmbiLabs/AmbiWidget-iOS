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
		TokenManager.loadTokenFromUserDefaults(with: .RefreshToken)
		.done { token in
			// Do nothing...
			
			// Debugging
			DeviceManager.API.getDeviceList()
			.map { arrayOfDevices -> ([Device]) in
				try DeviceManager.Local.saveDeviceList(deviceList: arrayOfDevices)
				let deviceList = try DeviceManager.Local.getDeviceList()
				return deviceList
			}.done { deviceList in
				print("getDeviceList: \(deviceList)")
			}.catch { error in
				print ("\(String(describing: self)) Error: \(error)")
			}
			
		}.catch { error in
			// Show auth view page
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "auth") as! AuthVC
			self.present(vc, animated: true, completion: nil)
		}
	}
}
