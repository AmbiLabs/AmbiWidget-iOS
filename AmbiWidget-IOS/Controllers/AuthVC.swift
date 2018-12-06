//
//  ViewController.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 26/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit

class AuthVC: UIViewController {
	
	// Authentication Url & Parameters
	let authoriseURL = "https://api.ambiclimate.com/oauth2/authorize"
	let responseType = "code"

    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(onAuthCodeReceive(_:)), name: .onAuthCodeReceive, object: nil)
    }

	@IBAction func authoriseButton(_ sender: UIButton) {
		
		// Construct & url encode the redirect URL
		let queryString = "client_id=" + APISettings.clientID + "&redirect_url=" + APISettings.callbackURL + "&response_type=" + responseType
		let url = URL(string: authoriseURL + "?" + queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
		
		// Open browser with redirect URL
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		} else {
			// Fallback on earlier versions
			UIApplication.shared.openURL(url)
		}
	}
	
	// When a user opens the app from browser (authentication) link.
	@objc func onAuthCodeReceive(_ notification: Notification) {
		let data = notification.userInfo as! [String: String]
		let authCode = data["authCode"]!
		
		TokenManager.authenticateApp(with: authCode)
		.map { tokens in
			try TokenManager.saveTokenToUserDefaults(token: tokens.accessToken)
			try TokenManager.saveTokenToUserDefaults(token: tokens.refreshToken)
		}.done{
			self.dismiss(animated: true)
			print("Dismissed the AuthVC")
		}.catch { error in
			print("Error: \(error)")
		}
	}
	
}

