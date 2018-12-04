//
//  MainVC.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 30/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// If refresh token does not exist, show auth view
		if (!TokenController.refreshTokenExists) {
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "auth") as! AuthVC
			self.present(vc, animated: true, completion: nil)
			return
		}
		
		// Debugging
		print("Test")
		DeviceManager.getDeviceList (completion: { (error: Error?, nameOfThrower: String?) -> Void in
			print("getDeviceList completed, error: \(error)")
		})
		
		
	}
}
