//
//  TokenController.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 27/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

class TokenController {
	
	private init(){}
	
	public static var refreshTokenExists: Bool {
		get {
			guard refreshToken != nil else {
				return false
			}
			return true
		}
	}
	
	public static var refreshToken: Token? {
		get {
			let type = TokenType.refreshToken
			return getToken(with: type)
		}
	}
	
	public static var accessToken: Token? {
		get {
			let type = TokenType.accessToken
			let token = getToken(with: type)
			
			// Check if token is expired
			if token != nil, token?.expiresIn != nil {
				let differenceInSeconds = Int(token!.creationDate.timeIntervalSinceNow * -1)
				//if (differenceInSeconds) + 30 > token!.expiresIn! {
				if (differenceInSeconds) + 30 > 40 {
					// Token is expired, removing it from UserDefaults
					UserDefaults.standard.removeObject(forKey: type.defaultsKey)
					print("[\(self)] Access Token has expired, deleted it from UserDefaults.")
					return nil
				}
			}
			
			return token
		}
	}
	
	// Returns a Token based on it's type. Also handles errors thrown by the Model.
	private static func getToken(with type: TokenType) -> Token? {
		var token: Token?
		do {
			token = try TokenManager.loadTokenFromUserDefaults(with: type)
		} catch {
			// If error loading Token, delete the token from user defaults
			UserDefaults.standard.removeObject(forKey: type.defaultsKey)
			print("[\(self)] Error loading \(type), deleted (json) string in UserDefaults.")
		}
		return token
	}
	
	// Called when the app receives an authCode from browser
	static func authoriseApp(with authCode: String) {
		
		TokenManager.authenticateAndSaveTokens(with: authCode, completion: { (error: Error?, nameOfThrower: String?) -> Void in
			
			// If there is an error
			if let error = error {
				print("[\(nameOfThrower ?? "Unknown")] \(error)")
				print("[\(self)] Failed to authorise app.")
				NotificationCenter.default.post(name: .onDidAuthentication, object: self, userInfo: ["success": false])
			} else {
				print("[\(self)] Successfully authorised the app!")
				NotificationCenter.default.post(name: .onDidAuthentication, object: self, userInfo: ["success": true])
			}
		})
	}
	
	
}
