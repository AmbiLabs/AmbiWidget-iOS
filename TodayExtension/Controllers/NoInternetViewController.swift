//
//  NoInternetViewController.swift
//  TodayExtension
//
//  Created by Brandon Yuen on 11/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import UIKit

class NoInternetViewController: UIViewController {
    
	@IBOutlet weak var noInternetLabel: UILabel!
	@IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add border radius to authorise button
        retryButton.layer.cornerRadius = 20
    }
    
    @IBAction func retryLoadingWidget(_ sender: UIButton) {
		NotificationCenter.default.post(name: .onReconnectButtonPressed, object: self)
    }
}
