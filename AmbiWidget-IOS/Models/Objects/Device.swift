//
//  Device.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 04/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

struct Device: Codable {
	let id: String
	let name: String
	let locationName: String
	var status: DeviceStatus? = nil
	
	init(id: String, name: String, locationName: String) {
		self.id = id
		self.name = name
		self.locationName = locationName
	}
	
	// Get the "simple" mode state of the device from the perspective of the Widget UI.
	// i.e. Ambi Open API does not specifically give us a "Off" Mode, but further data reading is required.
    var simpleMode: SimpleMode? {
        get {
            var simpleMode: SimpleMode?
            
            guard let rawMode = status?.applianceControlTarget.quantity.lowercased(), let applianceState = status?.applianceState else {
                return nil
            }
            
            // If device is off
            if (rawMode == "manual" && applianceState.power.lowercased() == "off") || rawMode == "off" {
                simpleMode = SimpleMode.Off
            }
            
            // If Manual mode
            if (rawMode == "manual" && applianceState.power.lowercased() != "off") {
                simpleMode = SimpleMode.Manual
            }
                
			// If Comfort mode
            else if rawMode == "climate" {
                simpleMode = SimpleMode.Comfort
            }
                
			// If Temperature mode
            else if rawMode == "temperature" {
                simpleMode = SimpleMode.Temperature
            }
				
			// If Away mode (temp. lower)
			else if rawMode == "away_temperature_lower" {
				simpleMode = SimpleMode.AwayTemperatureLower
			}
				
			// If Away mode (temp. upper)
			else if rawMode == "away_temperature_upper" {
				simpleMode = SimpleMode.AwayTemperatureUpper
			}
				
			// If Away mode (hum. upper)
			else if rawMode == "away_humidity_upper" {
				simpleMode = SimpleMode.AwayHumidityUpper
			}
            
            return simpleMode
        }
        
        set(newMode) {
            print("Simple mode is set to \(newMode)")
            switch newMode! {
            case .Off:
                self.status?.applianceControlTarget.quantity = "off"
            case .Comfort:
                self.status?.applianceControlTarget.quantity = "climate"
            case .Temperature:
                self.status?.applianceControlTarget.quantity = "temperature"
            default:
                return
            }
        }
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
