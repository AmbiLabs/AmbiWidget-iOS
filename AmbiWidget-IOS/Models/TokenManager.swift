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
	
	static func authenticateApp(with authCode: String) -> Promise<(refreshToken: Token, accessToken: Token)> {
		
		func authenticateAndFetchTokens(_ authCode:String) -> Promise<(data: Data, response: URLResponse)> {
			
			// Construct & encode the redirect URL
			let queryString = "client_id=\(APISettings.clientID)&redirect_uri=\(APISettings.callbackURL)&code=\(authCode)&client_secret=\(APISettings.clientSecret)&grant_type=authorization_code"
			let url = URL(string: tokenUrl + "?" + queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
			
			print(">>> [URL] \(url)")
			return URLSession.shared.dataTask(.promise, with: url)
		}
		
		func decodeData(_ data: Data) throws -> (refreshToken: Token, accessToken: Token) {
			
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
			
			let refreshToken = Token(code: refreshTokenCode, type: .refreshToken)
			let accessToken = Token(code: accessTokenCode, type: .accessToken, expiresIn: expiresIn)
			
			return (refreshToken, accessToken)
		}
		
		return firstly {
				authenticateAndFetchTokens(authCode)
			}.map { result in
				try decodeData(result.data)
		}
	}
	
	//
	// Authorises the app with an authCode by calling the Authentication API Endpoint
	//
	static func authenticateAndSaveTokens(with authCode: String, completion: @escaping (Error?, String?) -> Void) {
		
		// Construct & encode the redirect URL
		let queryString = "client_id=\(APISettings.clientID)&redirect_uri=\(APISettings.callbackURL)&code=\(authCode)&client_secret=\(APISettings.clientSecret)&grant_type=authorization_code"
		let url = URL(string: tokenUrl + "?" + queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
		
		print(">>> [URL] \(url)")
		
		// Authenticate in a background task and save access & refresh tokens
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			do {
				if let error = error {
					throw error
				}
				struct Result: Codable {
					let refresh_token: String?
					let access_token: String?
					let expires_in: Int?
					let error: String?
				}
				
				// Decode retrieved data with JSONDecoder
				guard let data = data else { throw TokenManagerError.noResultData(errorMessage: "No result data found.")}
				let result = try JSONDecoder().decode(Result.self, from: data)
				print("<<< \(result)")
				
				// If there is an error in the result
				if let error = result.error {
					throw TokenManagerError.resultHasError(errorMessage: error)
				}
				
				// If the refresh or access tokens are not in the result
				guard let refreshToken = result.refresh_token, let accessToken = result.access_token, let expiresIn = result.expires_in else {
					throw TokenManagerError.noResultData(errorMessage: "No tokens found in result data.")
				}
				
				// Save tokens to user defaults
				try saveTokenToUserDefaults(token: Token(code: refreshToken, type: .refreshToken))
				try saveTokenToUserDefaults(token: Token(code: accessToken, type: .accessToken, expiresIn: expiresIn))
				
				completion(nil, nil)
				
			} catch {
				completion(error, String(describing: self))
			}
		}.resume()
	}
	
	//
	// Gets a new access token from the API
	//
	private static func getNewAccessToken() -> Promise<Token> {
		print("[getNewAccessToken]")
		
		func fetchAccessTokenData(refreshToken: Token) -> Promise<(data: Data, response: URLResponse)> {
			// Construct & encode the redirect URL
			let queryString = "client_id=\(APISettings.clientID)&redirect_uri=\(APISettings.callbackURL)&refresh_token=\(refreshToken.code)&client_secret=\(APISettings.clientSecret)&grant_type=refresh_token"
			let url = URL(string: tokenUrl + "?" + queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
			print(">>> [URL] \(url)")
			return URLSession.shared.dataTask(.promise, with: url)
		}
		
		func decodeData(_ data:Data) throws -> Token? {
			
			struct Result: Codable {
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
			guard let accessTokenCode = result.access_token, let expiresIn = result.expires_in else {
				throw TokenManagerError.noResultData(errorMessage: "No access token or expiricy time found in result data.")
			}
			
			// Create Token from
			let accessToken = Token(code: accessTokenCode, type: .accessToken, expiresIn: expiresIn)
			
			// Save tokens to user defaults
			try saveTokenToUserDefaults(token: accessToken)
			
			return accessToken
		}
		
		return firstly {
			TokenManager.getRefreshToken()
		}.then { refreshToken in
			fetchAccessTokenData(refreshToken: refreshToken)
		}.compactMap { result in
			try decodeData(result.data)
		}
	}
	
	public static func getRefreshToken() -> Promise<Token> {
		
		return TokenManager.loadTokenFromUserDefaults(with: TokenType.refreshToken)
			.map { token in
				return token! // This is force-unwraped becaue loadTokenFromUserDefaults() should never actually return a nil token, but throw errors instead. And yes it MUST be an optional because Promise resolving needs a (result, err) as parameter. Meaning there is always a result, even when errors are handled.
		}
		
	}
	
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
		
		return TokenManager.loadTokenFromUserDefaults(with: TokenType.accessToken)
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
		UserDefaults.standard.set(tokenAsJson, forKey: token.type.defaultsKey)
		print("Saved '\(token.type)': \(token.code)")
	}
	
	//
	// Loads a Token from userDefaults based on it's type
	// throws errors if token could not be loaded (i.e doesn't exist or corruption error)
	//
	static func loadTokenFromUserDefaults(with tokenType: TokenType) -> Promise<Token?> {
		return Promise { seal in
			var token: Token?
			var err: Error?
			do {
				
				// Load token from UserDefaults as Json, if unable to load, return nil for Token?
				guard let tokenAsJson = UserDefaults.standard.string(forKey: tokenType.defaultsKey) else {
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
				UserDefaults.standard.removeObject(forKey: tokenType.defaultsKey)
				
				// ...and return a generalised error.
				err = TokenManagerError.tokenNotLoadable(errorMessage: "[\(self)] Error loading \(tokenType), deleted (json) string in UserDefaults.")
			}
			seal.resolve(token, err)
		}
	}
}
