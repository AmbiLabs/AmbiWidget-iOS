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
    private let device: Device
    
    init(device: Device) {
        self.device = device
    }
    
    public var deviceTitleText: String {
        // Check the user showDeviceLocation preference and make the deviceTitleText here.
        return device.name
    }
    
    public var temperatureLabel: String {
        // Do fahrenheit / celsius conversions here.
        return "\(device.temperature)"
    }
    
    public var humidityLabel: String {
        return "\(device.humidity)%"
    }
    
    public var modeIcon: UIImage {
        switch device.mode {
        case .comfort:
            return UIImage(named: "icn_mode_comfort")!
        case .temperature:
            return UIImage(named: "icn_mode_temperature")!
        case .manual:
            return UIImage(named: "icn_mode_manual")!
        case .off:
            return UIImage(named: "icn_mode_off_grey")!
        }
    }
}
