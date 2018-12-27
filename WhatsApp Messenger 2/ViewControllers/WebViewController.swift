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
    config.websiteDataStore = WKWebsiteDataStore.nonPersistent()

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

      HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
    }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.navigationController?.navigationBar.prefersLargeTitles = false

    let cookieStore =  webView.configuration.websiteDataStore.httpCookieStore
    cookieStore.add(self)

    self.webView.load(self.request)
//    self.deleteCookieData()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    let cookieStore =  webView.configuration.websiteDataStore.httpCookieStore
    cookieStore.remove(self)
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
//    let dataStore = WKWebsiteDataStore.default()
//    dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
//      for record in records {
//        dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
//          print("Deleted: " + record.displayName);
//
//          self.loadHTTPCookies()
//        })
//      }
//    }

    let cookieStorage = HTTPCookieStorage.shared
    if let cookies =  cookieStorage.cookies(for: Defaults.whatsappURL!), !cookies.isEmpty {
      for cookie in cookies {
        cookieStorage.deleteCookie(cookie)
        if cookies.last == cookie {
          self.loadHTTPCookies()
        }
      }
    }
    else {
      self.loadHTTPCookies()
    }

    /*
    let cookieStore =  webView.configuration.websiteDataStore.httpCookieStore
 DispatchQueue.main.async {
    cookieStore.getAllCookies({ (cookies) in
//      if cookies.isEmpty {
//         DispatchQueue.main.async {
//          self.webView.load(self.request)
//        }
//        return
//      }
      for cookie in cookies {
        DispatchQueue.main.async {
        cookieStore.delete(cookie, completionHandler: ({
          print("Deleted: " + cookie.name);
          if cookies.last == cookie {
            DispatchQueue.main.async {
              self.loadCookieData(fromChatRoom: self.chatRoom)
            }
          }
        }))
        }
      }
    })

    }
 */
  }

  func loadHTTPCookies() {
    let cookieStorage = HTTPCookieStorage.shared
    let cookies = self.getCookies(fromChatRoom: self.chatRoom)
    for cookie in cookies {
      cookieStorage.setCookie(cookie)
    }
    self.webView.load(self.request)
  }

  func loadCookieData(fromChatRoom room: ChatRoom) {
    let cookieStore =  webView.configuration.websiteDataStore.httpCookieStore
      let cookies = self.getCookies(fromChatRoom: room)
      for cookie in cookies {
      DispatchQueue.main.async {
        cookieStore.setCookie(cookie) {
          print("Loaded: " + cookie.name);
          if cookies.last == cookie {
            DispatchQueue.main.async {
              self.webView.reload()
            }
          }
        }
      }
    }
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

extension WebViewController: WKHTTPCookieStoreObserver {
  public func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
    DispatchQueue.main.async {
      cookieStore.getAllCookies({ (cookies) in

        let isLocalEmpty = UserDefaults.standard.value(forKey: "isLocalEmpty") as? Bool

        if !cookies.isEmpty {
          if isLocalEmpty == nil {
            DispatchQueue.main.async {
              self.chatRoom.saveCookies(browserCookies: cookies)
              print("Saved \(cookies)")
            }

            UserDefaults.standard.set(false, forKey: "isLocalEmpty")
          }
          else if isLocalEmpty == true {
            DispatchQueue.main.async {
              self.chatRoom.saveCookies(browserCookies: cookies)
              print("Saved \(cookies)")
            }

            UserDefaults.standard.set(false, forKey: "isLocalEmpty")
          }
          else {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
              for record in records {
                dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {

                  print("Deleted: " + record.displayName);
                  if record == records.last {
                    let chatCookies = self.getCookies(fromChatRoom: self.chatRoom)
                    if !chatCookies.isEmpty {
                      for chatCookie in chatCookies {
                        DispatchQueue.main.async {
                          cookieStore.setCookie(chatCookie) {
                            UserDefaults.standard.set(false, forKey: "isLocalEmpty")
                            print("Loaded: " + chatCookie.name);
                          }
                        }
                      }
                    }
                    else {
                      UserDefaults.standard.set(true, forKey: "isLocalEmpty")
                    }

                  }
                })
              }
            }

          }
        }
    })
    }
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
