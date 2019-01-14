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
    public let device: Device
    
    init(device: Device) {
        self.device = device
    }
    
    public var deviceTitleText: String {
        return device.name
    }
    
    public var locationNameText: String {
        return device.locationName
    }
    
    public var temperatureLabel: String {
		guard var value = device.temperature else {
			return "‒"
		}
		value = round(value * 10) / 10
		
		// Do fahrenheit / celsius conversions here.
		if UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.bool(forKey: UserDefaultsKeys.useFahrenheit) {
			value = round(Utils.temperatureInFahrenheit(celcius: value) * 10) / 10
		}
		
		return "\(value)°"
		
    }
    
    public var humidityLabel: String {
		guard var value = device.humidity else {
			return "‒"
		}
		value = round(value * 10) / 10
		return "\(value)%"
    }
    
    public var modeIcon: UIImage? {
		print("modeIcon getter: simpleMode = \(device.simpleMode)")
		
		guard let simpleMode = device.simpleMode else {
			return nil
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
		case .AwayHumidityUpper:
			return UIImage(named: "icn_mode_away")!
		case .AwayTemperatureLower:
			return UIImage(named: "icn_mode_away")!
		case .AwayTemperatureUpper:
			return UIImage(named: "icn_mode_away")!
		}
    }
}
