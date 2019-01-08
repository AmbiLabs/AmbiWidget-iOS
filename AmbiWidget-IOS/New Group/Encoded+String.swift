//
//  SubDelimited+String.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 08/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import Foundation

extension String {
	
	/// Returns a percent-escaped string following RFC 3986 for a query string key or value.
	///
	/// RFC 3986 states that the following characters are "reserved" characters.
	///
	/// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
	/// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
	///
	/// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
	/// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
	/// should be percent-escaped in the query string.
	///
	/// - parameter string: The string to be percent-escaped.
	///
	/// - returns: The percent-escaped string.
	
	public func encoded() -> String {
		let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
		let subDelimitersToEncode = "!$&'()*+,;="
		
		var allowedCharacterSet = CharacterSet.urlQueryAllowed
		allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
		
		var escaped = ""
		
		//==========================================================================================================
		//
		//  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
		//  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
		//  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
		//  info, please refer to:
		//
		//      - https://github.com/Alamofire/Alamofire/issues/206
		//
		//==========================================================================================================
		
		if #available(iOS 8.3, *) {
			escaped = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
		} else {
			let batchSize = 50
			var index = self.startIndex
			
			while index != self.endIndex {
				let startIndex = index
				let endIndex = self.index(index, offsetBy: batchSize, limitedBy: self.endIndex) ?? self.endIndex
				let range = startIndex..<endIndex
				
				let substring = self[range]
				
				escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
				
				index = endIndex
			}
		}
		
		return escaped
	}

}
