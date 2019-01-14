//
//  DeviceStatus.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 07/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

struct DeviceStatus: Codable {
	
	struct ApplianceControlTarget: Codable {
		var quantity: String
		var value: Double?
	}
	
	struct ApplianceState: Codable {
		var mode: String
		var power: String
	}
	
	struct ComfortPrediction: Codable {
		let comfort: Double
	}
	
	struct SensorData: Codable {
		let humidity_refined: Double
		let temperature_refined: Double
	}
	
	var applianceControlTarget: ApplianceControlTarget
	var applianceState: ApplianceState
	let comfortPrediction: ComfortPrediction
	let deviceOnline: Bool
	let sensorData: SensorData
}
