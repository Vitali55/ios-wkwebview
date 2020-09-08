//
//  SetupService.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/20/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import Foundation
import Appodeal

final class SetupService {
  
  private var rechabilityObserver = ReachabilityHandler()
  
  var isConnected: Bool {
    rechabilityObserver.hasConnection
  }
  
  func setupNetworkHandler() {
    rechabilityObserver.startMonitoring()
  }
  
  func removeNetworkHandler() {
    rechabilityObserver.stopMonitoring()
  }
  
  func setupAll() {
    setupNetworkHandler()
    setupAd()
    setupMetrika()
  }
  
  //MARK: - AD
  
  func setupAd() {
    Appodeal.initialize(
      withApiKey: "22ebd2ecccaf7238b2bcc0e62a91602445ecb5851d5aba0a",
      types: [AppodealAdType.interstitial, AppodealAdType.rewardedVideo],
      hasConsent: true
    )
  }
  
  func initAdsAggregator(hasConsent: Bool) {
    Appodeal.updateConsent(hasConsent)
  }
  
  // MARK: - Metrika
  
  func setupMetrika() {
    YandexMetricaAnalytics().initMetrica()
  }
}
