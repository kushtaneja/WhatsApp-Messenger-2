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
  var bannerView: GADBannerView! = {
    GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
  }()

  let request: URLRequest! = {
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.loadCookieData(fromChatRoom: self.chatRoom)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.navigationController?.navigationBar.prefersLargeTitles = false
    webView.load(request)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    saveCookieData(toChatRoom: self.chatRoom)
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
  }

  func deleteCookieData() {
    let dataStore = WKWebsiteDataStore.default()
    dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
      for record in records {
        dataStore.removeData(ofTypes: ["WKWebsiteDataTypeCookies", "WKWebsiteDataTypeFetchCache","WKWebsiteDataTypeOfflineWebApplicationCache","WKWebsiteDataTypeSessionStorage","WKWebsiteDataTypeWebSQLDatabases","WKWebsiteDataTypeIndexedDBDatabases"], for: [record], completionHandler: {
          print("Deleted: " + record.displayName);
        })
      }
    }


//    let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
//
//    cookieStore.getAllCookies({ (cookies) in
//      for cookie in cookies {
//        cookieStore.delete(cookie, completionHandler: ({
//                  print("Deleted: " + cookie.name);
//        }))
//      }
//    })
//    webView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()

  }

  func loadCookieData(fromChatRoom room: ChatRoom) {
      let cookies = getCookies(fromChatRoom: room)
      for cookie in cookies {
        WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie) {
          print("Loaded: " + cookie.name);
        }
      }
  }

  func saveCookieData(toChatRoom room: ChatRoom) {
    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies({ (cookies) in
     room.saveCookies(browserCookies: cookies)
      print("Saved \(cookies)")
      self.deleteCookieData()
    })
  }


  func getCookies(fromChatRoom room: ChatRoom)->[HTTPCookie] {
          var cookies = [HTTPCookie]()
          for chatCookie in room.cookies {
            let cookie = createCookie(cookie: chatCookie)
            cookies.append(cookie)
          }
          return cookies
  }

  func createCookie(cookie: ChatCookie) -> HTTPCookie {

    let cookieProperty: [HTTPCookiePropertyKey: Any] = [
      HTTPCookiePropertyKey.version: cookie.version,
      HTTPCookiePropertyKey.domain: cookie.domain,
      HTTPCookiePropertyKey.discard: "TRUE",
      HTTPCookiePropertyKey.path: "/pp",
      HTTPCookiePropertyKey.name: cookie.cookieName,
      HTTPCookiePropertyKey.value: cookie.cookieValue,
      HTTPCookiePropertyKey.secure: "TRUE",
      HTTPCookiePropertyKey.init(rawValue: "Created"): cookie.created.timeIntervalSinceReferenceDate]

    return HTTPCookie(properties: cookieProperty)!
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