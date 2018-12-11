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
let offNotificationKey = "tonglaicha.brandonmilan.off"

// TODO:
// 1) Fix the layout incorrect size bug
// 2) Off mode icon is not displayed when setting device to off mode
// 3) Switch the current device displayed

class TodayViewController: UIViewController, NCWidgetProviding {
    var deviceViewModels = [DeviceViewModel]()
    var currentDeviceViewModel: DeviceViewModel?
    
    @IBOutlet weak var modeContentView: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var modeIcon: UIImageView!
    
    // Notification names
    let modeSelection = Notification.Name(rawValue: modeSelectionNotificationKey)
    let comfortMode = Notification.Name(rawValue: comfortNotificationKey)
    let temperatureMode = Notification.Name(rawValue: temperatureNotificationKey)
    let offMode = Notification.Name(rawValue: offNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Do any additional setup after loading the view from its nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        createObservers()
        
        print("viewDidLoad: container size = \(modeContentView.frame.size)")
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        self.updateWidget()
        print("widgetPerformUpdate called")
        
        completionHandler(NCUpdateResult.newData)
    }
    
    public func updateWidget() {
        print("Updating the widget")
        
        self.currentDeviceViewModel = deviceViewModels[0]
        deviceNameLabel.text = currentDeviceViewModel!.deviceTitleText
        temperatureLabel.text = currentDeviceViewModel!.temperatureLabel
        humidityLabel.text = currentDeviceViewModel!.humidityLabel
        modeIcon.image = currentDeviceViewModel!.modeIcon
        
        // Set the initial childViewController for the modeContentView.
        add(currentDeviceViewModel!.modeSegmentView, viewContainer: modeContentView)
    }
    
    func fetchData() {
        // Get the device data from the API
        
        var devices = [Device]()
        devices.append(Device(name: "Bedroom Milan", location: "Home", temperature: 18.5, humidity: 77.0, mode: Device.Mode.comfort))
        devices.append(Device(name: "Living room", location: "Home", temperature: 19.2, humidity: 69.4, mode: Device.Mode.temperature))
        
        self.deviceViewModels = devices.map({return
            DeviceViewModel(device: $0)})
        print("fetchData: \(self.deviceViewModels)")
        
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.switchMode(notification:)), name: modeSelection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.switchMode(notification:)), name: comfortMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.switchMode(notification:)), name: temperatureMode, object: nil)
    }
    
    @objc func switchMode(notification: NSNotification) {
        // TODO: call mode switch to API, get updated device object, update widget
        switch notification.name {
        case comfortMode:
            currentDeviceViewModel?.device.mode = Device.Mode.comfort
            self.updateWidget()
        case temperatureMode:
            currentDeviceViewModel?.device.mode = Device.Mode.temperature
            self.updateWidget()
        case modeSelection:
            let modeSelectionVC = ModeSelection()
            add(modeSelectionVC, viewContainer: modeContentView)
        case offMode:
            currentDeviceViewModel?.device.mode = Device.Mode.off
            self.updateWidget()
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
