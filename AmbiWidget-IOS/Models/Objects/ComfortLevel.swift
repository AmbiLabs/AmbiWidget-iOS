//
//  ComfortLevel.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 12/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

enum ComfortLevel: String {
	case Freezing = "freezing"
	case TooCold = "too_cold"
	case BitCold = "bit_cold"
	case Comfortable = "comfortable"
	case BitWarm = "bit_warm"
	case TooWarm = "too_warm"
	case TooHot = "too_hot"
	
	init?(_ int: Int) {
		guard let comfortLevel = ComfortLevel.typeFromInt(int) else {
			return nil
		}
		self = comfortLevel
	}
	
	init?(_ double: Double) {
		guard let comfortLevel = ComfortLevel.typeFromInt(Int(double)) else {
			return nil
		}
		self = comfortLevel
	}
	
	private static func typeFromInt(_ int: Int) -> ComfortLevel? {
		switch int {
		case -3:
			return ComfortLevel.Freezing
		case -2:
			return ComfortLevel.TooCold
		case -1:
			return ComfortLevel.BitCold
		case 0:
			return ComfortLevel.Comfortable
		case 1:
			return ComfortLevel.BitWarm
		case 2:
			return ComfortLevel.TooWarm
		case 3:
			return ComfortLevel.TooHot
		default:
			return nil
		}
	}
}
