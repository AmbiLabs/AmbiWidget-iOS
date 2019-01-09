//
//  CustomEncoded+URL.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 08/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import Foundation

//
// Custom extension to create an encoded URL from baseUrl and queryParams
//
extension URL {
	
	init(baseUrl: String, queryParams: [String: String]?) {
		
		var encodedUrlString = baseUrl
		
		if queryParams != nil, queryParams!.count > 0 {
			
			var i = 0
			for (key, value) in queryParams! {
				i += 1; if i == 1 { encodedUrlString += "?" } else { encodedUrlString += "&" }
				encodedUrlString += "\(key)=\(value.encoded())"
			}
		}
		
		self = URL(string: encodedUrlString)!
	}
}
