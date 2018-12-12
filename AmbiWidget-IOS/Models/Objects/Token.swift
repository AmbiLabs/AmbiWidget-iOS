//
//  Token.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 27/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

enum TokenType {
	case RefreshToken
	case AccessToken
	
	var defaultsKey: String {
		get {
			switch self {
			case .RefreshToken:
				return UserDefaultsKeys.refreshToken
			case .AccessToken:
				return UserDefaultsKeys.accessToken
			}
		}
	}
}

extension TokenType: Codable {
	
	enum Key: CodingKey {
		case rawValue
	}
	
	enum CodingError: Error {
		case unknownValue
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Key.self)
		let type = try container.decode(String.self, forKey: .rawValue)
		switch type {
		case "refreshToken":
			self = .RefreshToken
		case "accessToken":
			self = .AccessToken
		default:
			throw CodingError.unknownValue
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: Key.self)
		switch self {
		case .RefreshToken:
			try container.encode("refreshToken", forKey: .rawValue)
		case .AccessToken:
			try container.encode("accessToken", forKey: .rawValue)
		}
	}
}

struct Token: Codable {
	let code: String
	let type: TokenType
	let creationDate: Date
	var expiresIn: Int?
	
	init(code: String, type: TokenType) {
		self.code = code
		self.type = type
		self.creationDate = Date.init()
		self.expiresIn = nil
	}
	
	init(code: String, type: TokenType, expiresIn: Int) {
		self.code = code
		self.type = type
		self.creationDate = Date()
		self.expiresIn = expiresIn
	}
	
	func asJson() throws -> String {
		let data = try JSONEncoder().encode(self)
		return String(data: data, encoding: .utf8)!
	}
}
