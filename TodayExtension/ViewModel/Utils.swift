//
//  Utils.swift
//  TodayExtension
//
//  Created by Brandon Yuen on 04/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import Foundation

class Utils {
	static func temperatureInFahrenheit(celcius: Double) -> Double {
		return celcius * 9 / 5 + 32
	}
}
