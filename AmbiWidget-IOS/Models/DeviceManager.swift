//
//  DeviceManager.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 03/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

enum DeviceManagerError: Error {
	case httpErrorCode(errorMessage: String)
}

class DeviceManager {
	private init(){}
	
	private static let deviceListUrl = "https://api.ambiclimate.com/api/v1/devices"
	private static let deviceStatusUrl = "https://api.ambiclimate.com/api/v1/device/device_status"
	
	//
	// Gets the device list from the open API
	//
	static func getDeviceList(completion: @escaping (Error?, String?) -> Void) {
		print("[getDeviceList]")
		
		guard let accessToken = TokenController.accessToken else {
			print("Access token not found, requesting new.")
			
			// Request new access token before continuing with device list call
			guard let refreshToken = TokenController.refreshToken?.code else {
				print("[\(self)] Error: Could not get refresh token for new access token request.")
				return
			}
			
			TokenManager.getNewAccessToken(with: refreshToken) { (error, nameOfThrower) -> Void in
				if let error = error {
					print("[\(nameOfThrower ?? "Unknown")] Error requesting new access token: \(error)")
					return
				} else {
					// New access token is saved, so we can re-execute the same request.
					getDeviceList(completion: completion)
				}
			}
			
			return
		}
		
		// Construct & encode the redirect URL
		let queryString = "&access_token=\(accessToken.code)"
		let url = URL(string: deviceListUrl + "?" + queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
		
		print(">>> [URL] \(url)")
		
		// Authenticate in a background task and save access & refresh tokens
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			do {
				if let error = error {
					throw error
				}
				
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
				guard let data = data else { throw TokenManagerError.noResultData(errorMessage: "No result data found.")}
				let result = try JSONDecoder().decode(Result.self, from: data)
				print("<<< \(result)")
				
				// If there is an error in the result
				if let errorCode = result.error_code {
					throw DeviceManagerError.httpErrorCode(errorMessage: "Error code: \(errorCode)")
				}
				
				completion(nil, nil)
				
			} catch {
				completion(error, String(describing: self))
			}
			}.resume()
	}
}
