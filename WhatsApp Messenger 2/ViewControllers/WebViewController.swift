//
//  WebViewController.swift
//  WhatsApp Messenger 2
//
//  Created by Kush Taneja on 03/11/18.
//  Copyright © 2018 Kush Taneja. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import WebKit

fileprivate struct Defaults {
  static let navBarHeight: CGFloat = 88
  static let gADBannerHeight: CGFloat = 100
  static let defaultSpacing: CGFloat = 4.0
  static let whatsappURL = URL(string:"https://web.whatsapp.com")
}


class WebViewController: UIViewController {

  var chatRoom: ChatRoom!
  var keys = [""]

  var bannerView: GADBannerView! = {
    GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
  }()

  var request: URLRequest! = {
    URLRequest(url: Defaults.whatsappURL!)
  }()


  var webView: WKWebView! = {
    let contentController = WKUserContentController()
    let scriptSource = "document.body.style.zoom = 1;"
    let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    contentController.addUserScript(script)

    let config = WKWebViewConfiguration()
    config.userContentController = contentController

    return WKWebView(frame: .zero, configuration: config)
  }()

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, room: ChatRoom) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.chatRoom = room
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

    override func viewDidLoad() {
      super.viewDidLoad()

      addBannerView(bannerView: self.bannerView)
      setupWebView()
    }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.navigationController?.navigationBar.prefersLargeTitles = false
    self.webView.load(self.request)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.saveDump()
  }


  func addBannerView(bannerView: GADBannerView) {
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)
    bannerView.topAnchor.constraint(equalTo: view.topAnchor, constant: Defaults.navBarHeight + 2*Defaults.defaultSpacing).isActive = true
    bannerView.heightAnchor.constraint(equalToConstant: Defaults.gADBannerHeight).isActive = true
    bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
    bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true

    bannerView.layer.cornerRadius = 16.0
    bannerView.layer.masksToBounds = true


    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = self
    bannerView.delegate = self

    let request: GADRequest = GADRequest()
    request.testDevices = [kGADSimulatorID]
    bannerView.load(request)
  }

  func setupWebView() {
    webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"

    view.addSubview(webView)

    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 2*Defaults.defaultSpacing).isActive = true
    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    webView.backgroundColor = UIColor.white

    webView.navigationDelegate = self
  }


  func saveDump() {
    webView.evaluateJavaScript("dump = {};for (i=0;i<localStorage.length;i++){dump[localStorage.key(i)]=localStorage.getItem(localStorage.key(i))}; b=JSON.stringify(dump);localStorage.clear();b") { (result, error) in

      let realm = try! Realm()
      try! realm.write {
        self.chatRoom.localStorageDump = result as? String
      }
    }
  }

  func loadStorage() {
    guard let dump = self.chatRoom.localStorageDump else {
      self.webView.load(self.request)
      return
    }

    webView.evaluateJavaScript("a=\(dump);for (key in a){localStorage.setItem(key,a[key]);}") { (result, error) in

      self.webView.load(self.request)
    }

  }
}

extension WebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.webView.navigationDelegate = nil
    self.loadStorage()
  }

}

  extension WebViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
