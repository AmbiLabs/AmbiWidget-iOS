//
//  DeviceViewModel.swift
//  TodayExtension
//
//  Created by Milan Sosef on 3/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation
import UIKit

class DeviceViewModel {
    // Change this to let later
    public var device: Device
    
    init(device: Device) {
        self.device = device
    }
    
    public var deviceTitleText: String {
        // TODO: Check the user showDeviceLocation preference and make the deviceTitleText here.
        return device.name
    }
    
    public var temperatureLabel: String {
        // Do fahrenheit / celsius conversions here.
        return "\(device.temperature)"
    }
    
    public var humidityLabel: String {
        return "\(device.humidity) %"
    }
    
    public var modeIcon: UIImage {
		
		guard let simpleMode = device.simpleMode else {
			return UIImage(named: "icn_mode_off_grey")!
		}
		
        switch simpleMode {
        case .Comfort:
            return UIImage(named: "icn_mode_comfort")!
        case .Temperature:
            return UIImage(named: "icn_mode_temperature")!
        case .Manual:
            return UIImage(named: "icn_mode_manual")!
        case .Off:
            return UIImage(named: "icn_mode_off_grey")!
        }
    }
}
