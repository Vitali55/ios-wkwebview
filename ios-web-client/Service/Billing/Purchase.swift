//
//  Purchase.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/21/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

final class Purchase: BillingService {
  
  var webBridge: WebViewBridge?
  
  func setBridge(webBridge: WebViewBridge) {
    self.webBridge = webBridge
  }
  
  func getProducts(productIds: [String]) {
    SwiftyStoreKit.retrieveProductsInfo(Set<String>(productIds)) { [weak self] result in
      if result.retrievedProducts.isEmpty == false {
        self?.handleProducts(products: result.retrievedProducts)
      } else if result.invalidProductIDs.isEmpty == false {
        let message = "Invalid product identifiers: \(result.invalidProductIDs)"
        self?.emitError(message: message)
      } else {
        let message = "Error: \(String(describing: result.error))"
        self?.emitError(message: message)
      }
    }
  }
  
  func purchase(productID: String) {
    SwiftyStoreKit.purchaseProduct(productID) { result in
      self.handlePurchase(result: result)
    }
  }
  
  func onPurchaseHistoryRestored() {
    SwiftyStoreKit.restorePurchases { [weak self] result in
      guard result.restoredPurchases.isEmpty else {
        self?.webBridge?.emitEvent(message: "onPurchaseHistoryRestored")
        return
      }
      
      self?.emitError(message: "onPurchaseHistoryFailed")
    }
  }
  
  static func finishTransactions() {
    SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
      for purchase in purchases {
        switch purchase.transaction.transactionState {
        case .purchased, .restored:
          if purchase.needsFinishTransaction {
            // Deliver content from server, then:
            SwiftyStoreKit.finishTransaction(purchase.transaction)
          }
        // Unlock content
        case .failed, .purchasing, .deferred:
          break // do nothing
        }
      }
    }
  }
  
  // MARK: - Private
  
  private func handlePurchase(result: PurchaseResult) {
    switch result {
    case .success(let purchase):
      let success = "Purchase Success: \(purchase.productId)"
      print(success)
      let joinedParams = (purchase.transaction.transactionIdentifier ?? "") + "|splitter|" + purchase.transaction.transactionState.debugDescription
      webBridge?.emitEvent(message: "onProductPurchased", joinedParams)
    case .error(let error):
        switch error.code {
        case .unknown:
          let error = "Unknown error. Please contact support"
          emitError(message: error)
        case .clientInvalid:
          let error = "Not allowed to make the payment"
          emitError(message: error)
        case .paymentCancelled:
          let error = "Not allowed to make the payment"
          emitError(message: error)
        case .paymentInvalid:
          let error = "The purchase identifier was invalid"
          emitError(message: error)
        case .paymentNotAllowed:
          let error = "The device is not allowed to make the payment"
          emitError(message: error)
        case .storeProductNotAvailable:
          let error = "The product is not available in the current storefront"
          emitError(message: error)
        case .cloudServicePermissionDenied:
          let error = "Access to cloud service information is not allowed"
          emitError(message: error)
        case .cloudServiceNetworkConnectionFailed:
          let error = "Could not connect to the network"
          emitError(message: error)
        case .cloudServiceRevoked:
          let error = "User has revoked permission to use this cloud service"
          emitError(message: error)
        default:
          let error = (error as NSError).localizedDescription
          emitError(message: error)
        }
    }
  }
  
  private func handleProducts(products: Set<SKProduct>) {
    let adoptedProducts = products.map { BillingModel(product: $0) }
    let data = adoptedProducts.toJson()
    webBridge?.emitEvent(message: "onGetStoreGoodsProducts", data)
  }
  
  private func emitError(message: String) {
    print(message)
    webBridge?.emitEvent(message: "onBillingError", message)
  }
}
