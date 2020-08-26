//
//  CaseRoyaleWebBridge.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/24/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import Foundation
import WebKit

enum ScriptMessage: String {
  
  case showAds
  case showInterstitialAds
  case getStoreProducts
  case purchaseStoreProduct
  case reportEvent
  case initAdsAggregator
}

final class CaseRoyaleWebBridge: WebViewBridge {
  
  private let webEntryPoint = "platform."//"webEntryPoint"
  private let messages:[ScriptMessage] = [
    .showAds,
    .showInterstitialAds,
    .getStoreProducts,
    .purchaseStoreProduct,
    .reportEvent,
    .initAdsAggregator
  ]
  
  private let webView: WKWebView
  
  init(webView: WKWebView) {
    self.webView = webView
    
    super.init(adService: ADService(), billing: Purchase(), analytics: YandexMetricaAnalytics())
    adService.update(strategy: RewardedVideoAD(webBridge: self))
    billing.setBridge(webBridge: self)
    
    messages.forEach {
      registerFor(message: $0.rawValue)
    }
  }
  
  func registerFor(message name: String) {
    webView.configuration.userContentController.add(self, name: name)
  }
  
  override func emitEvent(message: String, _ parameter: String = "") {
    let method = "emitEvent('" + message + "', '" + parameter  + "')"
    call(methodName: method)
  }
  
  
  func call(methodName: String) {
    let event = "window." + webEntryPoint + methodName
    webView.evaluateJavaScript(event) { [weak self] result, error in
      self?.handleEmit(result: result, error: error)
    }
  }
  
  private func handleEmit(result: Any?, error: Error?) {
    guard let error = error else {
      return
    }
    
    print(error.localizedDescription)
  }
  
  private func handle(message: WKScriptMessage) {
    switch message.name {
    case ScriptMessage.initAdsAggregator.rawValue:
      initAdsAggregator(message: message)
    case ScriptMessage.showInterstitialAds.rawValue:
      showInterstial()
    case ScriptMessage.showAds.rawValue:
      showRewardedVideo()
    case ScriptMessage.getStoreProducts.rawValue:
      getStoreProducts(message: message)
    case ScriptMessage.purchaseStoreProduct.rawValue:
      purchaseStoreProduct(message: message)
    case ScriptMessage.reportEvent.rawValue:
      reportEvent(message: message)
    default:
      return
    }
  }
  
  // MARK: - Services methods
  private func initAdsAggregator(message: WKScriptMessage) {
    guard let hasConsent = message.body as? Bool else {
      return
    }
    
    SetupService().initAdsAggregator(hasConsent: hasConsent)
  }
  
  private func showInterstial() {
    adService.update(strategy: InterstialAD(webBridge: self))
    adService.showAd()
  }
  
  private func showRewardedVideo() {
    adService.update(strategy: RewardedVideoAD(webBridge: self))
    adService.showAd()
  }
  
  private func getStoreProducts(message: WKScriptMessage) {
    guard let productIds = message.body as? String else {
      return
    }
    
    let products = productIds.trimCharacters("[\\[\\]\"]").components(separatedBy: ",")
    billing.getProducts(productIds: products)
  }
  
  private func purchaseStoreProduct(message: WKScriptMessage) {
    guard let productId = message.body as? String else {
      return
    }
    
    billing.purchase(productID: productId)
  }
  
  private func reportEvent(message: WKScriptMessage) {
    guard let params = message.body as? String else {
      return
    }
    
    analytics.reportEvent(eventName: params, eventParams: [:])
  }
}

extension CaseRoyaleWebBridge: WKScriptMessageHandler {
  
  func userContentController(
    _ userContentController:
    WKUserContentController,
    didReceive message: WKScriptMessage) {
    handle(message: message)
  }
}
