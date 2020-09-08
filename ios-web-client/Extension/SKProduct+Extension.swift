//
//  SKProduct+Extension.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/31/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import StoreKit
import SwiftyStoreKit

extension SKProduct {
  
  fileprivate static var formatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }
  
  var localizedPrice: String {
    self.priceLocale.currencyCode ?? ""
  }
}

extension Encodable {
  
  func dictionary() -> [String: Any]? {
    let encoder = JSONEncoder()
    
    guard let data = try? encoder.encode(self),
      let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
        return nil
    }

    return jsonObject as? [String: Any]
  }
}
