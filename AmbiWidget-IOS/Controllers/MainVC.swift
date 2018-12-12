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
			TokenManager.loadTokenFromUserDefaults(with: .RefreshToken)
		}.done { token in
			// Do nothing...
			
			// Debugging
			DeviceManager.getDeviceList().done { arrayOfDevices in
				print("Device List: ")
				for device in arrayOfDevices {
					if device.name.contains("Desk") {
						print(device)
						DeviceManager.getDeviceStatus(for: device)
							.done { deviceStatus in
								var newDevice = device
								newDevice.status = deviceStatus
								print("Name: \(newDevice.name)")
								print("Mode: \(newDevice.simpleMode!)")
								print("Temperature: \(newDevice.temperature!)")
								print("Humidity: \(newDevice.humidity!)")
								print("Comfort Level: \(newDevice.predictedComfort!.rawValue)")
								
							}.catch { error in
								print("Error: \(error)")
						}
						return
					}
				}
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
