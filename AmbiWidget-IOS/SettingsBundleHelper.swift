//
//  SettingsBundleHelper.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 14/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
	
	private struct SettingsBundleKeys {
		static let Reset = "RESET_APP_KEY"
		static let BuildVersionKey = "build_preference"
		static let AppVersionKey = "version_preference"
	} 
	
	class func checkAndExecuteSettings() {
		let userDefaults = UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!
		
		// If reset key is enabled, reset all data.
		if userDefaults.bool(forKey: SettingsBundleKeys.Reset) {
			userDefaults.set(false, forKey: SettingsBundleKeys.Reset)
			userDefaults.removeObject(forKey: UserDefaultsKeys.accessToken)
			userDefaults.removeObject(forKey: UserDefaultsKeys.refreshToken)
			userDefaults.removeObject(forKey: UserDefaultsKeys.deviceList)
			userDefaults.removeObject(forKey: UserDefaultsKeys.showDeviceLocation)
			userDefaults.removeObject(forKey: UserDefaultsKeys.useFahrenheit)
			userDefaults.removeObject(forKey: UserDefaultsKeys.currentDeviceId)
			print("=========[RESET ALL USERDEFAULTS]=========")
		}
	}
	
	class func setVersionAndBuildNumber() {
		let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
		UserDefaults.standard.set(version, forKey: "version_preference")
		let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
		UserDefaults.standard.set(build, forKey: "build_preference")
	}
}
