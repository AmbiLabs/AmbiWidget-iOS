//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Milan Sosef on 22/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        self.updateWidget()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func updateWidget() {
        print("Updating the widget")
        
        deviceName.text = "Bedroom"
        temperature.text = "24.2"
        humidity.text = "76.8"
    }
    
    @IBAction func touchComfortButton(_ sender: UIButton) {
        var comfortTag: String?
    
        switch sender.tag {
            case 1:
                comfortTag = "too_warm"
            case 2:
                comfortTag = "bit_warm"
            case 3:
                comfortTag = "comfy"
            case 4:
                comfortTag = "bit_cold"
            case 5:
                comfortTag = "too_cold"
            default:
                comfortTag = nil
        }
        
        print("\(comfortTag!) button clicked")
    }
    
    @IBAction func touchModeButton(_ sender: UIButton) {
        print("Mode button clicked")
    }
    
    @IBAction func touchRefreshButton(_ sender: UIButton) {
        print("refresh button clicked")
        
        self.updateWidget()
    }
    
    @IBAction func touchSettingsButton(_ sender: UIButton) {
        print("Settings button clicked")
    }
    
    @IBAction func touchSwitchDeviceButton(_ sender: UIButton) {
        var switchDirection: String?
        
        if sender.tag == 6 {
            switchDirection = "left"
        } else if sender.tag == 7 {
            switchDirection = "right"
        }
        print("Switch device button clicked with tag \(switchDirection!)")
    
    }
}
