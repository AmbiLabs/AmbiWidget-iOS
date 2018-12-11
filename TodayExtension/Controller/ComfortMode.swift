//
//  ComfortMode.swift
//  TodayExtension
//
//  Created by Milan Sosef on 4/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit

class ComfortMode: UIViewController {

    @IBOutlet var contentView: UIView!
    
    private enum ComfortFeedback {
        case too_warm
        case bit_warm
        case comfy
        case bit_cold
        case too_cold
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(contentView.frame.size)
        // Do any additional setup after loading the view.
        
//        var frm: CGRect = view.frame
//        frm.size.width = 320
//        contentView.frame = frm
    }
    
    @IBAction func touchComfortButton(_ sender: UIButton) {
        let feedback: ComfortFeedback?
        
        switch sender.tag {
        case 1:
            feedback = ComfortFeedback.too_warm
        case 2:
            feedback = ComfortFeedback.bit_warm
        case 3:
            feedback = ComfortFeedback.comfy
        case 4:
            feedback = ComfortFeedback.bit_cold
        case 5:
            feedback = ComfortFeedback.too_cold
        default:
            feedback = nil
        }
        
        print("\(feedback!) button clicked")
    }
    
    @IBAction func touchModeButton(_ sender: UIButton) {
        print("Mode button clicked")
        remove()
        let name = Notification.Name(rawValue: modeSelectionNotificationKey)
        NotificationCenter.default.post(name: name, object: nil)
    }

}
