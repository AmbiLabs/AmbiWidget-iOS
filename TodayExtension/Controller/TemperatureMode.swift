//
//  TemperatureMode.swift
//  TodayExtension
//
//  Created by Milan Sosef on 5/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit

class TemperatureMode: UIViewController {

    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(contentView.frame.size)
        
//        var frm: CGRect = view.frame
//        frm.size.width = 320
//        contentView.frame = frm
        // Do any additional setup after loading the view.
    }

    @IBAction func touchModeButton(_ sender: UIButton) {
        print("Mode button clicked")
        remove()
        let name = Notification.Name(rawValue: modeSelectionNotificationKey)
        NotificationCenter.default.post(name: name, object: nil)
    }

    @IBAction func touchAddTemperatureButton(_ sender: UIButton) {
        print("Add temperature button tapped")
    }
    
    @IBAction func touchDecreaseTemperatureButton(_ sender: UIButton) {
        print("Decrease temperature button tapped")
    }
}
