//
//  Device.swift
//  AmbiWidget-IOS
//
//  Created by Milan Sosef on 3/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

struct Device {
    public let name: String
    public let location: String
    public var temperature: Double
    public var humidity: Double
    public var mode: Mode
    
    public enum Mode {
        case comfort
        case temperature
        case manual
        case off
    }
    
    public init(name: String,
                location: String,
                temperature: Double,
                humidity: Double,
                mode: Mode) {
        self.name = name
        self.location = location
        self.temperature = temperature
        self.humidity = humidity
        self.mode = mode
    }
}
