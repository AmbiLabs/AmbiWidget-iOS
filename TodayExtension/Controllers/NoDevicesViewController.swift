//
//  NoDevicesViewController.swift
//  TodayExtension
//
//  Created by Milan Sosef on 07/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import UIKit

class NoDevicesViewController: UIViewController {

    @IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add border radius to authorise button
        retryButton.layer.cornerRadius = 20
    }

    @IBAction func touchRetryButton(_ sender: UIButton) {
        // Reload the widget.
        
    }
}
