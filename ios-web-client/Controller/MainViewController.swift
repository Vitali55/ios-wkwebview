//
//  ViewController.swift
//  ios-web-client
//
//  Created by Nazar Yavornytskyi on 8/20/20.
//  Copyright © 2020 apescodes. All rights reserved.
//

import UIKit
import WebKit

final class MainViewController: UIViewController {
  
  private var bridge: CaseRoyaleWebBridge?
  private let service = SetupService()
  
  lazy var configuration: WKWebViewConfiguration = {
    let preferences = WKPreferences()
    preferences.javaScriptEnabled = true
    
    let config = WKWebViewConfiguration()
    config.preferences = preferences
    
    return config
  }()
  
  private lazy var webView: WKWebView = {
    WKWebView(frame: .zero, configuration: configuration)
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.allowsLinkPreview = false
    
    webView.translatesAutoresizingMaskIntoConstraints = false
    
    bridge = CaseRoyaleWebBridge(webView: webView)
    
    prepare()
  }
  
  // MARK: - Private
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      webView.leftAnchor.constraint(equalTo: view.leftAnchor),
      webView.rightAnchor.constraint(equalTo: view.rightAnchor)
    ])
  }
  
  private func prepare() {
    setupWebView()
    
    NotificationCenter.default.addObserver(self, selector: #selector(reloadPage), name: .whenReachable, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(loadDisconnectedPage), name: .whenUnReachable, object: nil)
  }
  
  private func setupWebView() {
    webView.navigationDelegate = self
    view.addSubview(webView)
  }
  
  @objc private func reloadPage() {
    loadMainPage()
  }
  
  @objc private func loadDisconnectedPage() {
    loadTechnicalPage()
  }
  
  private func loadTechnicalPage(_ defaultHTTPPage: String = "disconnected") {
    if let url = Bundle.main.url(forResource: "disconnected", withExtension: "html", subdirectory: nil) {
      DispatchQueue.main.async { [weak self] in
        self?.webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        self?.webView.load(request)
      }
    }
  }
  
  private func loadMainPage() {
    if let url = URL(string: API.gameUrl) {
      webView.load(URLRequest(url: url))
    }
  }
}

extension MainViewController: WKNavigationDelegate {
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    print("started page loading")
    
    let url = webView.url?.absoluteString
    if url?.contains("file:///") == true && service.isConnected {
      loadMainPage()
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    print("finished page loading")
    
    bridge?.adService.updateState()
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("failed in page - \(error.localizedDescription)")
    let url = webView.url?.absoluteString
    if url?.contains("file:///") == false && url?.contains("socket.io") == false {
      loadTechnicalPage("technical-work")
    }
    
    showAlert(title: "Error", text: error.localizedDescription)
  }
}

extension MainViewController: WKScriptMessageHandler {
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    print("LOG WKWebView: \(message.body)")
  }
}

