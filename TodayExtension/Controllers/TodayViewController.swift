//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Milan Sosef on 22/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit
import NotificationCenter

// Should be in a constants file
let modeSelectionNotificationKey = "tonglaicha.brandonmilan.modeselection"
let comfortNotificationKey = "tonglaicha.brandonmilan.comfort"
let temperatureNotificationKey = "tonglaicha.brandonmilan.temperature"

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var modeContentView: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    // Notification names
    let modeSelection = Notification.Name(rawValue: modeSelectionNotificationKey)
    let comfortMode = Notification.Name(rawValue: comfortNotificationKey)
    let temperatureMode = Notification.Name(rawValue: temperatureNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        createObservers()
        
        let comfortModeViewController = ModeSelection()
        add(comfortModeViewController, viewContainer: modeContentView)
        
        print("container \(modeContentView.frame.size)" )
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        self.updateWidget()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    public func updateWidget() {
        print("Updating the widget")
        deviceNameLabel.text = "Bedroom"
        temperatureLabel.text = "24.2"
        humidityLabel.text = "76.8"
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.switchMode(notification:)), name: modeSelection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.switchMode(notification:)), name: comfortMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.switchMode(notification:)), name: temperatureMode, object: nil)
    }
    
    @objc func switchMode(notification: NSNotification) {
        switch notification.name {
        case modeSelection:
            let modeSelectionVC = ModeSelection()
            add(modeSelectionVC, viewContainer: modeContentView)
        case comfortMode:
            let comfortModeVC = ComfortMode()
            add(comfortModeVC, viewContainer: modeContentView)
        case temperatureMode:
            let temperatureModeVC = TemperatureMode()
            add(temperatureModeVC, viewContainer: modeContentView)
        default:
            print("default")
        }
        
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

extension UIViewController {
    func add(_ child: UIViewController, viewContainer: UIView) {
        addChild(child)
        viewContainer.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
