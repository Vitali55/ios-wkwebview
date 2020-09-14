//
//  WKWebView+Extension.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 9/14/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import WebKit

extension WKWebView {
  
  override open var safeAreaInsets: UIEdgeInsets {
    .zero
  }
}
