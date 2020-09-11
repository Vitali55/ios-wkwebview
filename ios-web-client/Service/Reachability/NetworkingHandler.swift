//
//  ReachabilityHandler.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/20/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import UIKit
import Reachability

final class NetworkingHandler {
  
  private let reachability = try! Reachability()
  
  // MARK: - LifeCycle
  
  deinit {
    stopMonitoring()
  }
  
  // MARK: - Public
  
  var hasConnection: Bool {
    reachability.connection != .unavailable
  }
  
  func startMonitoring() {
    stopMonitoring()
    
    do {
      try reachability.startNotifier()
    } catch{
      print("could not start reachability notifier")
    }
    
    reachability.whenReachable = { _ in
      NotificationCenter.default.post(name: .whenReachable, object: nil)
    }

    reachability.whenUnreachable = { _ in
      NotificationCenter.default.post(name: .whenUnReachable, object: nil)
    }
  }
  
  func stopMonitoring() {
    reachability.stopNotifier()
  }
}

extension Notification.Name {
  
  static let whenReachable = Notification.Name("WhenReachableNotification")
  static let whenUnReachable = Notification.Name("WhenUnReachableNotification")
}
