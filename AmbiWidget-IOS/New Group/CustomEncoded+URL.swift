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
	
	init(baseUrl: String, queryParams: [(key: String, value: String)]?) {
		
		var encodedUrlString = baseUrl
		
		if queryParams != nil, queryParams!.count > 0 {
			
			for i in 0..<queryParams!.count {
				if i == 0 { encodedUrlString += "?" } else { encodedUrlString += "&" }
				encodedUrlString += "\(queryParams![i].key)=\(queryParams![i].value.encoded())"
			}
		}
		
		self = URL(string: encodedUrlString)!
	}
}
