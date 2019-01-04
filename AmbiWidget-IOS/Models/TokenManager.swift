//
//  TokenModel.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 27/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation
import PromiseKit

enum TokenManagerError: Error {
	case noResultData(errorMessage: String)
	case resultHasError(errorMessage: String)
	case dataEncodingError(errorMessage: String)
	case jsonDecodingError(errorMessage: String)
	case tokenExpired(errorMessage: String)
	case tokenNotExist(errorMessage: String)
	case tokenNotLoadable(errorMessage: String)
}

class TokenManager {
	
	private init(){}
	
	private static let tokenUrl = "https://api.ambiclimate.com/oauth2/token"
	
	//
	// Authenticates the app with a user's Authorisation Code which he/she obtained from the Ambi Open API.
	// Return a promise for a Refresh Token and Access Token
	//
	static func authenticateApp(with authCode: String) -> Promise<(refreshToken: Token, accessToken: Token)> {
		
		func authenticateAndFetchTokens(_ authCode:String) -> Promise<(data: Data, response: URLResponse)> {
			
			// Construct & encode the URL
			var urlComp = URLComponents(string: tokenUrl)!
			var queryItems = [URLQueryItem]()
			queryItems.append(URLQueryItem(name: "client_id", value: APISettings.clientID))
			queryItems.append(URLQueryItem(name: "client_secret", value: APISettings.clientSecret))
			queryItems.append(URLQueryItem(name: "redirect_uri", value: APISettings.callbackURL))
			queryItems.append(URLQueryItem(name: "code", value: authCode))
			queryItems.append(URLQueryItem(name: "grant_type", value: "authorization_code"))
			urlComp.queryItems = queryItems
			let url = urlComp.url!
			print(">>> [URL] \(url)")
			
			return URLSession.shared.dataTask(.promise, with: url)
		}
		
		func decodeAndValidateData(_ data: Data) throws -> (refreshToken: Token, accessToken: Token) {
			
			struct Result: Codable {
				let refresh_token: String?
				let access_token: String?
				let expires_in: Int?
				let error: String?
			}
			
			// Decode retrieved data with JSONDecoder
			let result = try JSONDecoder().decode(Result.self, from: data)
			print("<<< \(result)")
			
			// If there is an error in the result
			if let error = result.error {
				throw TokenManagerError.resultHasError(errorMessage: error)
			}
			
			// If the refresh or access tokens are not in the result
			guard let refreshTokenCode = result.refresh_token, let accessTokenCode = result.access_token, let expiresIn = result.expires_in else {
				throw TokenManagerError.noResultData(errorMessage: "No tokens found in result data.")
			}
			
			let refreshToken = Token(code: refreshTokenCode, type: .RefreshToken)
			let accessToken = Token(code: accessTokenCode, type: .AccessToken, expiresIn: expiresIn)
			
			return (refreshToken, accessToken)
		}
		
		return firstly {
				authenticateAndFetchTokens(authCode)
			}.map { result in
				try decodeAndValidateData(result.data)
		}
	}
	
	//
	// Gets a new access token from the API
	// Will delete the refresh token if it appears to be invalid
	// NOTE: The deleteTokenFromUserDefaults() method will broadcast a notification for views
	//
	static func getNewAccessToken() -> Promise<Token> {
		print("[getNewAccessToken]")
		
		func fetchAccessTokenData(refreshToken: Token) -> Promise<(data: Data, response: URLResponse)> {
			// Construct & encode the URL
			var urlComp = URLComponents(string: tokenUrl)!
			var queryItems = [URLQueryItem]()
			queryItems.append(URLQueryItem(name: "client_id", value: APISettings.clientID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
			queryItems.append(URLQueryItem(name: "client_secret", value: APISettings.clientSecret.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
			queryItems.append(URLQueryItem(name: "redirect_uri", value: APISettings.callbackURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
			queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken.code.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
			queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
			urlComp.queryItems = queryItems
			let url = urlComp.url!
			print(">>> [URL] \(url)")
			
			return URLSession.shared.dataTask(.promise, with: url)
		}
		
		func decodeAndValidateData(_ rawResult:(data: Data, urlResponse: URLResponse)) throws -> Token? {
			
			struct Result: Codable {
				let access_token: String?
				let expires_in: Int?
				let error: String?
			}
			
			// Decode retrieved data with JSONDecoder
			let result = try JSONDecoder().decode(Result.self, from: rawResult.data)
			print("<<< \(result)")
			
			// Check for errors in httpResponse
			let httpResponse = rawResult.urlResponse as! HTTPURLResponse
			if let error = ErrorHelper.checkHttpStatusCode(statusCode: httpResponse.statusCode) {
				
				// If error was because of unauthorised (401) it means the refresh_token is invalid
				if case .unauthorised = error {
					print("[\(String(describing: self))] Could not get new Access Token because the Refresh Token is not valid.")
					deleteTokenFromUserDefaults(with: TokenType.RefreshToken)
				}
				
				throw error
			}
			
			// If there is an error in the result
			if let error = result.error {
				throw TokenManagerError.resultHasError(errorMessage: error)
			}
			
			// If the refresh or access tokens are not in the result
			guard let accessTokenCode = result.access_token, let expiresIn = result.expires_in else {
				throw TokenManagerError.noResultData(errorMessage: "No access token or expiricy time found in result data.")
			}
			
			// Create Token from
			let accessToken = Token(code: accessTokenCode, type: .AccessToken, expiresIn: expiresIn)
			
			// Save tokens to user defaults
			try saveTokenToUserDefaults(token: accessToken)
			
			return accessToken
		}
		
		return firstly {
			TokenManager.loadTokenFromUserDefaultsAsPromise(with: TokenType.RefreshToken)
		}.then { refreshToken in
			fetchAccessTokenData(refreshToken: refreshToken!)// This is force-unwraped becaue loadTokenFromUserDefaults() should never actually return a nil token, but throw errors instead. And yes it MUST be an optional because Promise resolving needs a (result, err) as parameter. Meaning there is always a result, even when errors are handled.
		}.compactMap { result in
			try decodeAndValidateData(result)
		}
	}
	
	//
	// Returns a Promise for an Access Token
	// Will also check if it's expired and fetch a new one from the API
	//
	public static func getAccessToken() -> Promise<Token> {
		
		func checkIfExpired(_ token: Token?) -> Promise<Token> {
			return Promise { seal in
				var err: Error?
				
				// Check if token is expired
				let differenceInSeconds = Int(token!.creationDate.timeIntervalSinceNow * -1)
				if (differenceInSeconds) + 30 > token!.expiresIn! {
					
					// Token is expired
					err = TokenManagerError.tokenExpired(errorMessage: "Access Token has expired, deleted it from UserDefaults.")
				}
				
				seal.resolve(token, err)
			}
		}
		
		return TokenManager.loadTokenFromUserDefaultsAsPromise(with: TokenType.AccessToken)
			.then { token in
				checkIfExpired(token)
			}.recover { error in
				TokenManager.getNewAccessToken()
			}.map { token in
				return token
		}
		
	}
	
	//
	// Saves a token to UserDefaults based on it's Type
	//
	static func saveTokenToUserDefaults(token: Token) throws {
		let tokenAsJson = try token.asJson()
		UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.set(tokenAsJson, forKey: token.type.defaultsKey)
		print("Saved '\(token.type)': \(token.code)")
	}
	
	//
	// Loads a Token from userDefaults based on it's type
	// throws errors if token could not be loaded (i.e doesn't exist or corruption error)
	//
	static func loadTokenFromUserDefaultsAsPromise(with tokenType: TokenType) -> Promise<Token?> {
		return Promise { seal in
			var token: Token?
			var err: Error?
			do {
				
				// Load token from UserDefaults as Json, if unable to load, return nil for Token?
				guard let tokenAsJson = UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.string(forKey: tokenType.defaultsKey) else {
					throw TokenManagerError.tokenNotExist(errorMessage: "Token of type '\(tokenType)' does not exist.")
				}
				
				// Encode jsonString to Data
				guard let data = tokenAsJson.data(using: .utf8) else {
					throw TokenManagerError.dataEncodingError(errorMessage: "Could not encode json \(tokenAsJson) to Data")
				}
				
				// Decode the Data to a Token
				token = try JSONDecoder().decode(Token.self, from: data)
				
				print("Loaded '\(tokenType)': '\(token?.code)'")
			} catch {
				// If there is ANY error loading Token, delete the token from user defaults...
				deleteTokenFromUserDefaults(with: tokenType)
				
				// ...and return a generalised error.
				err = TokenManagerError.tokenNotLoadable(errorMessage: "[\(self)] Error loading \(tokenType), deleted (json) string in UserDefaults.")
			}
			seal.resolve(token, err)
		}
	}
	
	//
	// Loads a Token from userDefaults based on it's type
	// throws errors if token could not be loaded (i.e doesn't exist or corruption error)
	//
	static func loadTokenFromUserDefaults(with tokenType: TokenType) throws -> Token? {
		var token: Token?
		do {
			// Load token from UserDefaults as Json, if unable to load, return nil for Token?
			guard let tokenAsJson = UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.string(forKey: tokenType.defaultsKey) else {
				throw TokenManagerError.tokenNotExist(errorMessage: "Token of type '\(tokenType)' does not exist.")
			}
			
			// Encode jsonString to Data
			guard let data = tokenAsJson.data(using: .utf8) else {
				throw TokenManagerError.dataEncodingError(errorMessage: "Could not encode json \(tokenAsJson) to Data")
			}
			
			// Decode the Data to a Token
			token = try JSONDecoder().decode(Token.self, from: data)
			
			print("Loaded '\(tokenType)': '\(token?.code)'")
		} catch {
			// If there is ANY error loading Token, delete the token from user defaults...
			deleteTokenFromUserDefaults(with: tokenType)
			
			// ...and return a generalised error.
			throw TokenManagerError.tokenNotLoadable(errorMessage: "[\(self)] Error loading \(tokenType), deleted (json) string in UserDefaults.")
		}
		return token
	}
	
	static func deleteTokenFromUserDefaults(with tokenType: TokenType) {
		UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.removeObject(forKey: tokenType.defaultsKey)
		
		// Post a notification to let views know that the app is unauthorised
		if (tokenType == TokenType.RefreshToken) {
			NotificationCenter.default.post(name: .onRefreshTokenDelete, object: self)
		}
	}
}
