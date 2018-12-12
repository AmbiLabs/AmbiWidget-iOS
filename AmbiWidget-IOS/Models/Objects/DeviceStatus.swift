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
		let quantity: String
		let value: Double?
	}
	
	struct ApplianceState: Codable {
		let mode: String
		let power: String
	}
	
	struct ComfortPrediction: Codable {
		let comfort: Double
	}
	
	struct SensorData: Codable {
		let humidity_refined: Double
		let temperature_refined: Double
	}
	
	let applianceControlTarget: ApplianceControlTarget
	let applianceState: ApplianceState
	let comfortPrediction: ComfortPrediction
	let sensorData: SensorData
}
