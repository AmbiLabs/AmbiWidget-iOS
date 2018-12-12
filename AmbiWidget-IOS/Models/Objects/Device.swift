//
//  Device.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 04/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

enum SimpleMode {
	case Off
	case Comfort
	case Temperature
}

struct Device: Codable {
	let id: String
	let name: String
	let locationName: String?
	var status: DeviceStatus? = nil
	
	init(id: String, name: String, locationName: String) {
		self.id = id
		self.name = name
		self.locationName = locationName
	}
	
	// Get the "simple" mode state of the device from the perspective of the Widget UI.
	// i.e. Ambi Open API does not specifically give us a "Off" Mode, but further data reading is required.
	var simpleMode: SimpleMode? {
		var simpleMode: SimpleMode?
		
		guard let applianceControlTarget = status?.applianceControlTarget, let applianceState = status?.applianceState else {
			return nil
		}
		
		// If device is off
		if (applianceControlTarget.quantity.lowercased() == "manual" && applianceState.power.lowercased() == "off") || applianceControlTarget.quantity.lowercased() == "off" {
			simpleMode = SimpleMode.Off
		}
		
		// If Comfort mode
		else if applianceControlTarget.quantity.lowercased() == "climate" {
			simpleMode = SimpleMode.Comfort
		}
		
		// If Temperature mode
		else if applianceControlTarget.quantity.lowercased() == "temperature" {
			simpleMode = SimpleMode.Temperature
		}
		
		return simpleMode
	}
	
	var temperature: Double? {
		return status?.sensorData.temperature_refined
	}
	
	var humidity: Double? {
		return status?.sensorData.humidity_refined
	}
	
	var predictedComfort: ComfortLevel? {
		guard let comfortLevelAsDouble = status?.comfortPrediction.comfort else {
			return nil
		}
		
		return ComfortLevel(comfortLevelAsDouble)
	}
}