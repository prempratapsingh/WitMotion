//
//  PrivacyAgreementViewController.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit
import WebKit

class PrivacyAgreementViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Private properties
    
    var webView: WKWebView!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("privacyAgreement", comment: "")
        self.view.backgroundColor = .white
        
        self.setupWebView()
        self.presentPrivacyAgreementDetails()
    }
    
    // MARK: - Private methods
    
    private func setupWebView() {
        self.webView = WKWebView(frame: UIScreen.main.bounds)
        self.webView.scrollView.bounces = false
        self.webView.scrollView.showsVerticalScrollIndicator = false
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
    }
    
    private func presentPrivacyAgreementDetails() {
        if let path = Bundle.main.path(forResource: "privacyAgreement", ofType: "html") {
            let url = URL(fileURLWithPath: path)
            self.webView.load(URLRequest(url: url))
        }
    }
    
    // MARK: - WKNavigationDelegate methods
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {}
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
}
