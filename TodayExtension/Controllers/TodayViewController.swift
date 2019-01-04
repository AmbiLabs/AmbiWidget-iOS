//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Milan Sosef on 22/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit
import NotificationCenter

// TODO:
// 1) Fix deviceViewmodelIndex not saved after widgetPerformUpdate.
// 2) DONE Fix icons changing to white color.

class TodayViewController: UIViewController, NCWidgetProviding {
    var deviceViewModels: [DeviceViewModel]?
    var deviceViewModelIndex: Int = 0
    
    enum SwitchDirection {
        case left
        case right
    }
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var modeIcon: UIImageView!
    
    @IBOutlet weak var buttonRow: UIStackView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Do any additional setup after loading the view from its nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.buttonRow.isHidden = true
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.buttonRow.isHidden = false
            self.preferredContentSize = CGSize(width: maxSize.width, height: 220)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        updateWidgetViews()
        updateLocalDeviceList()
        completionHandler(NCUpdateResult.newData)
    }
    
    public func updateWidgetViews() {
        print("Updating widget views")
        
        // Get deviceList from local storage.
        guard let localDeviceList = try? DeviceManager.Local.getDeviceList() else {
            // TODO: Show loading screen
            
            // If local storage is empty.
            updateLocalDeviceList()
            return
        }
        
        // Update deviceViewModels from local storage.
        self.deviceViewModels = localDeviceList.map({ return
            DeviceViewModel(device: $0)})
        
        guard let currentDeviceViewModel = self.deviceViewModels?[deviceViewModelIndex] else {
            // Something went wrong?
            return
        }
        print("index \(self.deviceViewModelIndex)")
        
        self.deviceNameLabel.text = currentDeviceViewModel.deviceTitleText
        self.locationNameLabel.text = currentDeviceViewModel.locationNameText
        self.temperatureLabel.text = currentDeviceViewModel.temperatureLabel
        self.humidityLabel.text = currentDeviceViewModel.humidityLabel
        self.modeIcon.image = currentDeviceViewModel.modeIcon
        
        print("Updated view with local device status.")
    }
    
    func updateLocalDeviceList() {
        print("Updating local device list")
        
        // Get new device data from the API
        DeviceManager.API.getDeviceList()
            .then { newDeviceList in
                DeviceManager.API.getDeviceStatus(for: newDeviceList)
            }.done { updatedDeviceList in
                print("Today View Controller: updatedDeviceList: \(updatedDeviceList)")
                
                // Save deviceList to local storage
                try! DeviceManager.Local.saveDeviceList(deviceList: updatedDeviceList)
                
                // Update widget views
                self.updateWidgetViews()
            }.catch { error in
                print("Error: \(error)")
        }
    }
    @IBAction func GiveComfortFeedback(_ sender: UIButton) {
        // Get deviceList from local storage.
        let localDeviceList = try! DeviceManager.Local.getDeviceList()
        let currentDevice = localDeviceList[deviceViewModelIndex]
        
        var comfortLevel: ComfortLevel?
        print(sender.tag)
        if sender.tag == 1 {
            comfortLevel = .BitWarm
        } else if sender.tag == 2 {
            comfortLevel = .BitCold
        }
        
        // Send comfort feedback to the API.
        DeviceManager.API.giveComfortFeedback(for: currentDevice, with: comfortLevel!).done { success in
            success ? print("Feedback given: \(comfortLevel!)") :
                print("Something went wrong while trying to give feedback \(comfortLevel!)")
            }.catch { error in
                print("Error: \(error)")
        }
    }
    
    @IBAction func switchToComfortMode(_ sender: UIButton) {
        // Get deviceList from local storage.
        let localDeviceList = try! DeviceManager.Local.getDeviceList()
        let currentDevice = localDeviceList[deviceViewModelIndex]
        
        // Send comfort mode instruction to the API.
        DeviceManager.API.comfortMode(for: currentDevice, with: SimpleMode.Comfort).done { success in
            success ? print("The device has been set to comfort mode.") :
                print("Failed to set the device to comfort mode.")
            }.catch { error in
                print("Error: \(error)")
        }
    }
    
    
    @IBAction func switchDeviceToOffMode(_ sender: UIButton) {
        // Get deviceList from local storage.
        let localDeviceList = try! DeviceManager.Local.getDeviceList()
        let currentDevice = localDeviceList[deviceViewModelIndex]
        
        // Send power off instruction to the API.
        DeviceManager.API.powerOff(for: currentDevice).done { success in
            success ? print("The device has been set to off mode") : print("Failed to set device to off mode.")
            }.catch { error in
                print("Error: \(error)")
        }
    }
    
//    @IBAction func touchSettingsButton(_ sender: UIButton) {
//        print("Settings button clicked")
//
//        let myAppUrl = NSURL(string: "widgetcontainingapp://")!
//        extensionContext?.open(myAppUrl as URL, completionHandler: { (success) in
//            if (!success) {
//                // let the user know it failed
//                print("Error: something went wrong when tried opening the app...")
//            }
//        })
//    }
    
    @IBAction func touchSwitchDeviceButton(_ sender: UIButton) {
        var direction: SwitchDirection?
        
        if sender.tag == 6 {
            direction = .left
        } else if sender.tag == 7 {
            direction = .right
        }
        switchDevice(with: direction!)
    }
    
    func switchDevice(with direction: SwitchDirection) {
        switch direction {
        case .left:
            if deviceViewModelIndex + 1 == deviceViewModels!.endIndex {
                deviceViewModelIndex = 0
            } else {
                deviceViewModelIndex += 1
            }
        case .right:
            if deviceViewModelIndex - 1 < deviceViewModels!.startIndex {
                deviceViewModelIndex = deviceViewModels!.endIndex - 1
            } else {
                deviceViewModelIndex -= 1
            }
        }
		
		// Update view
        self.updateWidgetViews()
    }
    
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
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
