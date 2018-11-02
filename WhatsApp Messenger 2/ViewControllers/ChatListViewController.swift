//
//  ChatListViewController.swift
//  WhatsApp Messenger 2
//
//  Created by Kush Taneja on 03/11/18.
//  Copyright © 2018 Kush Taneja. All rights reserved.
//

import UIKit
import Firebase


class ChatListViewController: UIViewController {

  var bannerView: GADBannerView! = {
    GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
  }()

  var tableView: UITableView! = {
    UITableView(frame: CGRect.zero, style: .grouped)
  }()

  var placeholderView: UIView! = {
    UIView(frame: CGRect.zero)
  }()

  var createButton: UIButton! = {
    UIButton(frame: CGRect.zero)
  }()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
        super.viewDidLoad()

    addBannerView(bannerView: self.bannerView)
    }

  func addBannerView(bannerView: GADBannerView) {
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    bannerView.backgroundColor = .black
    view.addSubview(bannerView)
    bannerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
    bannerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = self
    bannerView.delegate = self

    let request: GADRequest = GADRequest()
    request.testDevices = [kGADSimulatorID]
    bannerView.load(request)
  }
}


extension ChatListViewController: GADBannerViewDelegate {
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
