//
//  DeviceManager.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 03/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation
import PromiseKit

enum DeviceManagerError: Error {
	case httpErrorCode(errorMessage: String)
	case noDeviceListInResult(errorMessage: String)
	case invalidRefreshToken(errorMessage: String)
}

class DeviceManager {
	private init(){}
	
	private static let deviceListUrl = "https://api.ambiclimate.com/api/v1/devices"
	private static let deviceStatusUrl = "https://api.ambiclimate.com/api/v1/device/device_status"
	
	//
	// Gets the device list from the open API
	//
	static func getDeviceList() -> Promise<[Device]> {
		
		func fetchDeviceListData(accessToken: Token) -> Promise<(data: Data, response: URLResponse)> {
			// Construct & encode the redirect URL
			let queryString = "access_token=\(accessToken.code)"
			let url = URL(string: deviceListUrl + "?" + queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
			print(">>> [URL] \(url)")
			return URLSession.shared.dataTask(.promise, with: url)
		}
		
		func decodeData(_ data: Data) throws -> [Device] {
			
			struct DeviceResult: Codable {
				let device_id: String
				let location_name: String
				let room_name: String
			}
			
			struct Result: Codable {
				let data: [DeviceResult]?
				let error_code: Int?
			}
			
			// Decode retrieved data with JSONDecoder
			let result = try JSONDecoder().decode(Result.self, from: data)
			print("<<< \(result)")
			
			// If there is an error in the result
			if let errorCode = result.error_code {
				if errorCode > 399 && errorCode < 500 {
					throw DeviceManagerError.invalidRefreshToken(errorMessage: "\(errorCode): RefreshToken not valid?")
				}
				throw DeviceManagerError.httpErrorCode(errorMessage: "Error code: \(errorCode)")
			}
			
			guard let rawDeviceList = result.data else {
				throw DeviceManagerError.noDeviceListInResult(errorMessage: "No device list found in result.")
			}
			
			var deviceList = [Device]()
			
			// Create Array of Devices from result data
			for device in rawDeviceList {
				deviceList.append(Device(ID: device.device_id, name: device.room_name, locationName: device.room_name))
			}
			
			return deviceList
		}
		
		return firstly {
			TokenManager.getAccessToken()
		}.then { accessToken in
			fetchDeviceListData(accessToken: accessToken)
		}.compactMap { result in
			try decodeData(result.data)
		}
	}
}
