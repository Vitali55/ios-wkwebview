//
//  BillingModel.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/28/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import Foundation
import StoreKit

struct BillingModel: Codable {
  
  var currency: String
  var description: String
  var title: String
  var subscriptionPeriod: String
  var subscriptionFreeTrialPeriod: String
  var productId: String
  var introductoryPricePeriod: String
  var introductoryPriceText: String
  var priceValue: String
  var priceText: String
  var priceLong: Double
  var introductoryPriceLong: Double
  var introductoryPriceValue: Double
  var isSubscription: Bool
  var introductoryPriceCycles: Int
  var haveTrialPeriod: Bool
  var haveIntroductoryPeriod: Bool
  
  init(product: SKProduct) {
    currency = product.localizedPrice
    description = product.localizedDescription
    title = product.localizedTitle
    subscriptionPeriod = product.subscriptionPeriod == nil ? "" : product.subscriptionPeriod.debugDescription
    subscriptionFreeTrialPeriod = product.localizedSubscriptionPeriod
    productId = product.productIdentifier
    introductoryPricePeriod = ""
    introductoryPriceText = ""
    priceValue = product.price.description
    priceText = product.localizedPrice
    priceLong = Double(truncating: product.price)
    introductoryPriceLong = Double(truncating: product.price)
    introductoryPriceValue = Double(truncating: product.price)
    isSubscription = false
    introductoryPriceCycles = 0
    haveTrialPeriod = false
    haveIntroductoryPeriod = false
  }
}
