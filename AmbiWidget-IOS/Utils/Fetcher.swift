//
//  Fetcher.swift
//  AmbiWidget-IOS
//
//  Created by Brandon Yuen on 27/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import Foundation

class Fetcher {
	
	static func getData(from url: URL) throws -> String {
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			if error != nil {
				print(error!.localizedDescription)
			}
			
			guard let data = data else { return }
		
			// Do something with data
			print(data)
			
		}.resume()
		
		return "test"
	}
}
