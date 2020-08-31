//
//  SKProduct+Extension.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/31/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import StoreKit

extension SKProduct {
  fileprivate static var formatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }
  
  var localizedPrice: String {
    if self.price == 0.00 {
      return "None"
    } else {
      let formatter = SKProduct.formatter
      formatter.locale = self.priceLocale
      
      guard let formattedPrice = formatter.string(from: self.price) else {
        return "Unknown Price"
      }
      
      return formattedPrice
    }
  }
}
