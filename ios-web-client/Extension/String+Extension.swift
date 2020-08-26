//
//  String+Extension.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/27/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import Foundation

extension String {
  
  func trimCharacters(_ characters: String) -> String {
    replacingOccurrences(of: characters, with: "", options: .regularExpression, range: nil)
  }
}
