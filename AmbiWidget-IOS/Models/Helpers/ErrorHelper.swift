//
//  ErrorHelper.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 06/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation
import PromiseKit

enum HttpError: Error {
	case unauthorised(errorMessage: String)
	case unknown(errorMessage: String)
	case serviceUnavailable(errorMessage: String)
}

class ErrorHelper {
	
	private init(){}
	
	
	//
	// Checks for http errors within rawResult from server
	// Rejects promise and returns error based on http statusCodes
	//
	public static func checkForHttpError(_ rawResult: (data: Data, response: URLResponse)) -> Promise<(data: Data, response: URLResponse)> {
		
		return Promise { seal in
			var err: Error?
			// Check for errors in httpResponse
			let httpResponse = rawResult.response as! HTTPURLResponse
			if let error = ErrorHelper.checkHttpStatusCode(statusCode: httpResponse.statusCode) { err = error }
			seal.resolve(rawResult, err)
		}
	}
	
	//
	// Checks the checkHttpStatusCode and identfies errors
	// Returns an Optional Error
	//
	public static func checkHttpStatusCode(statusCode: Int) -> HttpError? {
		var error: HttpError?
		
		// 200 - 299 (Success)
		if (statusCode >= 200 && statusCode <= 299) {
			return nil
		}
		
		// 300 - 399 (Redirection)
		else if (statusCode >= 300 && statusCode <= 399) {
			error = HttpError.unknown(errorMessage: "Error (\(statusCode)): Unknown redirection error")
		}
		
		// 400 - 499 (Client Error)
		else if (statusCode >= 400 && statusCode <= 499) {
			switch statusCode {
			case 401:
				error = HttpError.unauthorised(errorMessage: "Error (\(statusCode)): Unauthorised request.")
			default:
				error = HttpError.unknown(errorMessage: "Error (\(statusCode)): Unknown client error.")
			}
		}
			
		// 500 - 599 (Server Error)
		else if (statusCode >= 500 && statusCode <= 599) {
			switch statusCode {
			case 503:
				error = HttpError.serviceUnavailable(errorMessage: "Error (\(statusCode)): Service unavailable.")
			default:
				error = HttpError.unknown(errorMessage: "Error (\(statusCode)): Unknown server error.")
			}
		}
		
		return error
	}
}
