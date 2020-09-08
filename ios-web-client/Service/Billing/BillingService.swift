//
//  BillingService.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/22/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import Foundation

protocol BillingService {
  
  var receiptData: String { get }
  
  func setBridge(webBridge: WebViewBridge)
  func getProducts(productIds: [String])
  func purchase(productID: String)
  func onPurchaseHistoryRestored()
}
