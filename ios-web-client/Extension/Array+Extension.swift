//
//  Array+Extension.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/31/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import Foundation

extension Array {
  
  func toJson() -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
      return ""
    }
    
    return String(data: data, encoding: String.Encoding.utf8) ?? ""
  }
}
