//
//  SimpleMode.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 09/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import Foundation

//
// SimpleMode is an enum representing simplefied type names.
// We call it SimpleMode because i.e. Off mode does not actually exist for Ambi's backend.
// Thus we need to read the deviceStatus (appliance state data) to determine Off mode.
//
enum SimpleMode {
	case Off
	case Comfort
	case Temperature
	case Manual
	case AwayTemperatureLower
	case AwayTemperatureUpper
	case AwayHumidityUpper
	case Disconnected
}
