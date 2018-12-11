//
//  User.swift
//  AmbiWidget-IOS
//
//  Created by Milan Sosef on 3/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

// MARK: - Model
public class User {
    private enum PreferredTemperatureScale {
        case celsius
        case fahrenheit
    }
    
    private let deviceList: [Device]
    private var showDeviceLocation: Bool
    private var preferredTemperatureScale: PreferredTemperatureScale
    private var isAuthenticated: Bool
    private var hasInternetConnection: Bool
    
    private init(deviceList: [Device],
                showDeviceLocation: Bool,
                temperatureScale: PreferredTemperatureScale,
                isAuthenticated: Bool,
                hasInternetConnection: Bool) {
        self.deviceList = deviceList
        self.showDeviceLocation = showDeviceLocation
        self.preferredTemperatureScale = temperatureScale
        self.isAuthenticated = isAuthenticated
        self.hasInternetConnection = hasInternetConnection
    }
}
