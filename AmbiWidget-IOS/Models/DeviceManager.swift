//
//  DeviceManager
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 03/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation
import PromiseKit

enum DeviceManagerError: Error {
	case invalidAccessToken(errorMessage: String)
	case errorInResult(errorMessage: String)
	case noDeviceListInResult(errorMessage: String)
	case noDeviceStatusInResult(errorMessage: String)
	case noDataInResult(errorMessage: String)
	case noDeviceListInUserDefaults(errorMessage: String)
	case noDevicesForAccount(errorMessage: String)
	case jsonEncodingError(errorMessage: String)
}

class DeviceManager {
	private init(){}
	
	class API {
		private init(){}
		
		// Api Endpoints
		private static let deviceListUrl = "https://api.ambiclimate.com/api/v1/devices"
		private static let deviceStatusUrl = "https://api.ambiclimate.com/api/v1/device/device_status"
		private static let comfortFeedbackUrl = "https://api.ambiclimate.com/api/v1/user/feedback"
		private static let temperatureModeUrl = "https://api.ambiclimate.com/api/v1/device/mode/temperature"
		private static let powerOffUrl = "https://api.ambiclimate.com/api/v1/device/power/off"
		private static let setComfortModeUrl = "https://api.ambiclimate.com/api/v1/device/mode/comfort"
		
		private enum RequestType {
			case deviceList
			case deviceStatus
			case comfortFeedback
			case temperatureMode
			case powerOff
			case setComfortMode
			
			// Get the associated URL for type of Data
			func getUrl(_ accessToken: Token, _ device: Device?, _ feedback: ComfortLevel?, _ modeValue: String?) -> URL {
				switch self {
				case .deviceList:
					let baseUrl = deviceListUrl
					let queryParams = ["access_token": accessToken.code]
					return URL(baseUrl: baseUrl, queryParams: queryParams)
					
				case .deviceStatus:
					let baseUrl = deviceStatusUrl
					let queryParams = ["access_token": accessToken.code,
									   "device_id": device!.id]
					return URL(baseUrl: baseUrl, queryParams: queryParams)
					
				case .comfortFeedback:
					let baseUrl = comfortFeedbackUrl
					let queryParams = ["access_token": accessToken.code,
									   "room_name": device!.name,
									   "location_name": device!.locationName,
									   "value": feedback!.rawValue]
					return URL(baseUrl: baseUrl, queryParams: queryParams)
					
				case .temperatureMode:
					let baseUrl = temperatureModeUrl
					let queryParams = ["access_token": accessToken.code,
									   "room_name": device!.name,
									   "location_name": device!.locationName,
									   "value": modeValue!]
					return URL(baseUrl: baseUrl, queryParams: queryParams)
					
				case .powerOff:
					let baseUrl = powerOffUrl
					let queryParams = ["access_token": accessToken.code,
									   "room_name": device!.name,
									   "location_name": device!.locationName]
					return URL(baseUrl: baseUrl, queryParams: queryParams)
					
				case .setComfortMode:
					let baseUrl = setComfortModeUrl
					let queryParams = ["access_token": accessToken.code,
									   "room_name": device!.name,
									   "location_name": device!.locationName]
					return URL(baseUrl: baseUrl, queryParams: queryParams)
				}
			}
		}
		
		//
		// Fetches Data from an URL that is based on the given dataType
		// If the accessToken appears to be invalid it will try to recover itself by
		// getting a new access token and re-executing the fetch on itself.
		//
		private static func fetchData(for dataType: RequestType, with accessToken: Token, by device: Device? = nil, byMultiple devices: [Device]? = nil, feedback: ComfortLevel? = nil, modeValue: String? = nil, isRetry: Bool = false) -> Promise<(data: Data, response: URLResponse)> {
			let url = dataType.getUrl(accessToken, device, feedback, modeValue)
			print(">>> [URL] \(url)")
			
			return URLSession.shared.dataTask(.promise, with: url)
				.then { result in
					ErrorHelper.checkForHttpError(result)
				}.recover { error -> Promise<(data: Data, response: URLResponse)> in
					// If error was thrown because of unauthorised (401) it means the access token is invalid
					// so we can try to recover by getting a new access token and re-executing the request.
					// NOTE: This should never have to happen as the getAccessToken() method already has an expiricy check.
					
					// If error is not an unauthorised (401) error, throw error anyway.
					guard case HttpError.unauthorised = error else {
						throw error
					}
					
					// If this was already a re-try, throw the error anyway. (To prevent infinite looping)
					if isRetry {
						TokenManager.deleteTokenFromUserDefaults(with: .AccessToken)
						throw DeviceManagerError.invalidAccessToken(errorMessage: "Invalid access token even though I tried with a new one.")
					}
					
					// Retry same request, but get a new access token first.
					print("[\(String(describing: self))] Error: Invalid access token, getting new access token and trying again...")
					
					return TokenManager.getNewAccessToken()
						.then { accessToken in
							// Retry fetching of data with new access token
							return DeviceManager.API.fetchData(for: dataType, with: accessToken, by: device, isRetry: true)
					}
					
			}
		}
		
		//
		// Gets the device list from the open API
		//
		static func getDeviceList() -> Promise<[Device]> {
			
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
				let decodedData = try JSONDecoder().decode(Result.self, from: data)
				print("<<< {device list} \(decodedData)")
				
				guard let rawDeviceList = decodedData.data else {
					throw DeviceManagerError.noDeviceListInResult(errorMessage: "No device list found in result.")
				}
				
				var deviceList = [Device]()
				
				// Create Array of Devices from result data
				for device in rawDeviceList {
					deviceList.append(Device(id: device.device_id, name: device.room_name, locationName: device.location_name))
				}
				
				// If device list is empty, throw error. (We need atleast 1 device)
				if deviceList.count < 1 {
					throw DeviceManagerError.noDevicesForAccount(errorMessage: "No devices found for this account.")
				}
				
				return deviceList
			}
			
			return firstly {
				TokenManager.getAccessToken()
				}.then { accessToken in
					DeviceManager.API.fetchData(for: RequestType.deviceList, with: accessToken)
				}.compactMap { result in
					try decodeData(result.data)
			}
		}
		
		//
		// Gets the device status from the open API
		//
		static func getDeviceStatus(for device: Device) -> Promise<DeviceStatus> {
			
			func decodeData(_ data: Data) throws -> DeviceStatus {
				
				struct Result: Codable {
					let appliance_control_target: DeviceStatus.ApplianceControlTarget?
					let appliance_state: DeviceStatus.ApplianceState?
					let comfort_prediction: DeviceStatus.ComfortPrediction?
					let device_online: Bool?
					let sensor_data: DeviceStatus.SensorData?
					let error: String?
				}
				
				// Decode retrieved data with JSONDecoder
				let decodedData = try JSONDecoder().decode(Result.self, from: data)
				print("<<< {device status} \(decodedData)")
				
				// Check for errors in result
				if let error = decodedData.error {
					throw DeviceManagerError.errorInResult(errorMessage: error)
				}
				
				// Check if all required parameters are present
				guard let applianceControlTarget = decodedData.appliance_control_target,
					let applianceState = decodedData.appliance_state,
					let comfortPrediction = decodedData.comfort_prediction,
					let deviceOnline = decodedData.device_online,
					let sensorData = decodedData.sensor_data
					else {
						throw DeviceManagerError.noDeviceStatusInResult(errorMessage: "DeviceStatus result is not complete.")
				}
				
				return DeviceStatus(
					applianceControlTarget: applianceControlTarget,
					applianceState: applianceState,
					comfortPrediction: comfortPrediction,
					deviceOnline: deviceOnline,
					sensorData: sensorData
				)
			}
			
			return TokenManager.getAccessToken()
				.then { accessToken in
					DeviceManager.API.fetchData(for: RequestType.deviceStatus, with: accessToken, by: device)
				}.compactMap { result in
					try decodeData(result.data)
			}
		}
		
		//
		// Gets the device status from the open API for multiple devices
		// Returns an updated array of devices: [Device] (NOT a single deviceStatus instance)
		//
		static func getDeviceStatus(for deviceList: [Device]) -> Promise<[Device]> {
			
			return TokenManager.getAccessToken()
				.then { accessToken in
					
					return Promise { seal in
						var updatedDeviceList = [Device]()
						var amountOfCompleted = 0
						var error: Error?
						
						for device in deviceList {
							var newDevice = device
							getDeviceStatus(for: device).done { deviceStatus in
								newDevice.status = deviceStatus
							}.ensure {
								updateDevice(newDevice: newDevice)
							}.cauterize()
						}
						
						func updateDevice(newDevice: Device) {
							updatedDeviceList.append(newDevice)
							amountOfCompleted = amountOfCompleted + 1
							if amountOfCompleted == deviceList.count {
								print("!!! Updated \(amountOfCompleted) devices with new status.")
								seal.resolve(updatedDeviceList, error)
							}
						}
					}
				}
				.map { result in
					return result
			}
		}
		
		//
		// Give comfort feedback to the AI
		//
		static func giveComfortFeedback(for device: Device, with feedback: ComfortLevel) -> Promise<Bool> {
			print("feedback: \(feedback)")
			
			func decodeData(_ data: Data) throws -> Bool {
				
				struct Result: Codable {
					let counts_unlocking: Bool?
					let created_on: String?
					let device_id: String?
					let feedback: Int?
					let origin: String?
					let error: String?
				}
				
				// Decode retrieved data with JSONDecoder
				let decodedData = try JSONDecoder().decode(Result.self, from: data)
				print("<<< {comfort feedback} \(decodedData)")
				
				// Check for errors in result
				if let error = decodedData.error {
					throw DeviceManagerError.errorInResult(errorMessage: error)
				}
				
				return true
			}
			
			return TokenManager.getAccessToken()
				.then { accessToken in
					DeviceManager.API.fetchData(for: RequestType.comfortFeedback, with: accessToken, by: device, feedback: feedback)
				}.compactMap { result in
					try decodeData(result.data)
			}
		}
		
		//
		// Set the mode of the ambi device
		//
		static func comfortMode(for device: Device, with simpleMode: SimpleMode) -> Promise<Bool> {
			
			func decodeData(_ data: Data) throws -> Bool {
				
				struct Result: Codable {
					let status: String?
					let status_code: Int?
				}
				
				// Decode retrieved data with JSONDecoder
				let decodedData = try JSONDecoder().decode([Result].self, from: data)
				print("<<< {comfort mode} \(decodedData)")
				
				// Check for errors in result
				guard let status = decodedData[0].status else {
					throw DeviceManagerError.noDataInResult(errorMessage: "No status found in result.")
				}
				
				if status == "ok" {
					return true
				} else {
					return false
				}
			}
			
			return TokenManager.getAccessToken()
				.then { accessToken in
					DeviceManager.API.fetchData(for: RequestType.setComfortMode, with: accessToken, by: device)
				}.compactMap { result in
					try decodeData(result.data)
			}
		}
		
		//
		// Update Mode
		//
		static func temperatureMode(for device: Device, with value: String) -> Promise<Bool> {
			
			func decodeData(_ data: Data) throws -> Bool {
				
				struct Result: Codable {
					let status: String?
					let status_code: Int?
				}
				
				// Decode retrieved data with JSONDecoder
				let decodedData = try JSONDecoder().decode([Result].self, from: data)
				print("<<< {temperatute mode} \(decodedData)")
				
				// Check for errors in result
				guard let status = decodedData[0].status else {
					throw DeviceManagerError.noDataInResult(errorMessage: "No status found in result.")
				}
				
				if status == "ok" {
					return true
				} else {
					return false
				}
			}
			
			return TokenManager.getAccessToken()
				.then { accessToken in
					DeviceManager.API.fetchData(for: RequestType.temperatureMode, with: accessToken, by: device, modeValue: value)
				}.compactMap { result in
					try decodeData(result.data)
			}
		}
		
		//
		// Give comfort feedback to the AI
		//
		static func powerOff(for device: Device) -> Promise<Bool> {
			
			func decodeData(_ data: Data) throws -> Bool {
				
				struct Result: Codable {
					let status: String?
					let status_code: Int?
				}
				
				// Decode retrieved data with JSONDecoder
				let decodedData = try JSONDecoder().decode([Result].self, from: data)
				print("<<< {power off} \(decodedData)")
				
				// Check for errors in result
				guard let status = decodedData[0].status else {
					throw DeviceManagerError.noDataInResult(errorMessage: "No status found in result.")
				}
				
				// If status is 'device offline' it means the server could not reach the Ambi Device,
				// however the appliance target is still set to off mode. Therefore OUR request for off is still a success.
				// TODO: Maybe show the user that their device is not actually in OFF mode now, because it couldn't be reached
				if status == "ok" || status == "device offline" {
					return true
				} else {
					return false
				}
			}
			
			return TokenManager.getAccessToken()
				.then { accessToken in
					DeviceManager.API.fetchData(for: RequestType.powerOff, with: accessToken, by: device)
				}.compactMap { result in
					try decodeData(result.data)
			}
		}
	}
	
	class Local {
		private init(){}
		
		//
		// Saves a deviceList to UserDefaults
		//
		static func saveDeviceList(deviceList: [Device]) throws {
			let data = try JSONEncoder().encode(deviceList)
			let deviceListAsJson = String(data: data, encoding: .utf8)!
			UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.set(deviceListAsJson, forKey: UserDefaultsKeys.deviceList)
			print("Saved device list (\(deviceList.count)) to UserDefaults")
		}
		
		//
		// Loads a Token from userDefaults based on it's type
		// throws errors if token could not be loaded (i.e doesn't exist or corruption error)
		//
		static func getDeviceList() throws -> [Device] {
			var deviceList: [Device]
				
			// Load token from UserDefaults as Json, if unable to load, return nil for Token?
			guard let deviceListAsJson = UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.string(forKey: UserDefaultsKeys.deviceList) else {
				throw DeviceManagerError.noDeviceListInUserDefaults(errorMessage: "Device List does not exist.")
			}
			
			// Encode jsonString to Data
			guard let data = deviceListAsJson.data(using: .utf8) else {
				throw DeviceManagerError.jsonEncodingError(errorMessage: "Could not encode json \(deviceListAsJson) to Data")
			}
				
			// Decode the Data to a Token
			deviceList = try JSONDecoder().decode([Device].self, from: data)
			
			return deviceList
		}
	}
}
