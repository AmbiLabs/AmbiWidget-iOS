//
//  ModeSelection.swift
//  TodayExtension
//
//  Created by Milan Sosef on 5/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit

class ModeSelection: UIViewController {

    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var frm: CGRect = view.frame
//        frm.size.width = 320
//        contentView.frame = frm
        
//        print(contentView.frame.size)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func touchModeButton(_ sender: UIButton) {
        var modeTag: String?
        var notificationName: Notification.Name?
        
        switch sender.tag {
        case 1:
            modeTag = "comfort"
            notificationName = Notification.Name(rawValue: Constants.comfortNotificationKey)
            remove()
        case 2:
            modeTag = "temperature"
            notificationName = Notification.Name(rawValue: Constants.temperatureNotificationKey)
            remove()
        case 3:
            modeTag = "off"
            notificationName = Notification.Name(rawValue: Constants.modeSelectionNotificationKey)
        default:
            modeTag = nil
        }
        
        // Send a notification to the observer in TodayViewController
        NotificationCenter.default.post(name: notificationName!, object: nil)
        
//        print("\(modeTag!) button clicked")
    }

}
