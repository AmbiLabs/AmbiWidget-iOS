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
		
		NotificationCenter.default.addObserver(self, selector: #selector(onDidAuthentication(_:)), name: .onDidAuthentication, object: nil)
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
	
	@objc func onDidAuthentication(_ notification: Notification) {
		let data = notification.userInfo as! [String: Bool]
		if (data["success"]!) {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
}

