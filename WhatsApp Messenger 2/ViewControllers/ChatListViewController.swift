//
//  ChatListViewController.swift
//  WhatsApp Messenger 2
//
//  Created by Kush Taneja on 03/11/18.
//  Copyright © 2018 Kush Taneja. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

fileprivate struct Defaults {
  static let navBarHeight: CGFloat = 140
  static let gADBannerHeight: CGFloat = 100
  static let defaultSpacing: CGFloat = 4.0
  static let placeholderText: String = "Add as many WhatsApp accounts\n you want. \n It's simple and free."
}

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

  var placeholderLabel: UILabel! = {
    UILabel(frame: CGRect.zero)
  }()

  var createButton: UIButton! = {
    UIButton(frame: CGRect.zero)
  }()

  let nameInputAlert: UIAlertController! = {
    UIAlertController(title: "Add Account", message: "Input WhatsApp Name", preferredStyle: UIAlertController.Style.alert)
  }()

  var addBarButtonItem: UIBarButtonItem?

  var chatRooms: [ChatRoom] {
    let realm = try! Realm()

    var rooms = [ChatRoom]()

    for room in realm.objects(ChatRoom.self) {
        rooms.append(room)
    }
    return rooms
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    addNavItems()
    addBannerView(bannerView: self.bannerView)
    initaliseTableView()
    createNameInputAlertView()
    addPlaceholderView()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    validatePlaceHolderView()
    self.navigationController?.navigationBar.prefersLargeTitles = true
  }

  func addPlaceholderView() {
    placeholderView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(placeholderView)
    placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    placeholderView.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor, constant: 0.0).isActive = true
    placeholderView.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor, constant: 0.0).isActive = true
    placeholderView.heightAnchor.constraint(equalToConstant: 150).isActive = true


    addPlaceholderLabel()
    addCreateButton()

    placeholderView.isHidden = true
  }

  func validatePlaceHolderView() {
      placeholderView.isHidden = chatRooms.count != 0
      tableView.isHidden = chatRooms.count == 0
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

  func addNavItems() {
    self.title = "WhatsApp"
    self.navigationController?.title = "WhatsApp"
    self.navigationController?.navigationBar.prefersLargeTitles = true

    addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add
      , target: self, action: #selector(didTapCreateButton))
    navigationItem.rightBarButtonItem = addBarButtonItem
  }

  func addPlaceholderLabel() {
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    let attributedString = NSMutableAttributedString(string: Defaults.placeholderText)

    // *** Create instance of `NSMutableParagraphStyle`
    let paragraphStyle = NSMutableParagraphStyle()

    // *** set LineSpacing property in points ***
    paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points

    // *** Apply attribute to string ***
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

    // *** Set Attributed String to your label ***
    placeholderLabel.attributedText = attributedString
    placeholderLabel.numberOfLines = 0

    placeholderLabel.textColor = UIColor.lightGray
    placeholderLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    placeholderLabel.textAlignment = .center

    placeholderView.addSubview(placeholderLabel)

    placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor).isActive = true
    placeholderLabel.topAnchor.constraint(equalTo: placeholderView.topAnchor).isActive = true
    placeholderLabel.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor, constant: 16.0).isActive = true
    placeholderLabel.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor, constant: -16.0).isActive = true
  }

  func addCreateButton() {
    createButton.translatesAutoresizingMaskIntoConstraints = false
    createButton.setTitle("Add Account", for: .normal)
    createButton.backgroundColor = UIColor.iosBlue
    createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    createButton.layer.cornerRadius = 8.0
    createButton.layer.masksToBounds = true
    createButton.setTitleColor(UIColor.white, for: .normal)
    placeholderView.addSubview(createButton)

    createButton.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor).isActive = true
    createButton.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: Defaults.defaultSpacing*4).isActive = true
    createButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    createButton.widthAnchor.constraint(equalToConstant: 120).isActive = true

    createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
  }

  func createNameInputAlertView() {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let createAction = UIAlertAction(title: "Add", style: .default) { (alertAction) in
      let textField = self.nameInputAlert.textFields![0] as UITextField
      if let name = textField.text {
        textField.text = ""
        self.addChatRoom(withName: name)
      }
    }

    nameInputAlert.addTextField { (textField) in
      textField.placeholder = "Enter your name"
    }

    nameInputAlert.addAction(cancelAction)
    nameInputAlert.addAction(createAction)
  }

  @objc func didTapCreateButton() {
    self.present(nameInputAlert, animated:true, completion: nil)
  }

  func addChatRoom(withName name: String) {
    let newChatRoom = ChatRoom(accountName: name, id: chatRooms.count, browserCookies: [])
    let realm = try! Realm()
    try! realm.write {
      realm.create(ChatRoom.self, value: newChatRoom, update: true)
    }

    nameInputAlert.dismiss(animated: true, completion: nil)
    validatePlaceHolderView()
    self.tableView.reloadData()
  }

  func initaliseTableView() {
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: Defaults.defaultSpacing).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    tableView.backgroundColor = UIColor.white


    tableView.delegate = self
    tableView.dataSource = self
    tableView.isHidden = true

    tableView.register(ChatRoomTableViewCell.self, forCellReuseIdentifier: "ChatRoomTableViewCell")
  }
}

extension ChatListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Accounts"
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let realm = try! Realm()
    tableView.deselectRow(at: indexPath, animated: true)

    guard let chatRoom = realm.object(ofType: ChatRoom.self, forPrimaryKey: indexPath.row) else {
      return
    }
    let webVC = WebViewController(nibName: "WebViewController", bundle: nil, room: chatRoom)
    self.navigationController?.pushViewController(webVC, animated: true)
  }
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
      let realm = try! Realm()
      try! realm.write {
        guard let object = realm.object(ofType: ChatRoom.self, forPrimaryKey: indexPath.row) else {
          return
        }
        realm.delete(object)
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
      tableView.reloadData()
      self.validatePlaceHolderView()
      completionHandler(true)
    }
    let swipeAction = UISwipeActionsConfiguration(actions: [delete])
    swipeAction.performsFirstActionWithFullSwipe = true // This is the line which disables full swipe
    return swipeAction
  }

}

extension ChatListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatRooms.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomTableViewCell", for: indexPath)
    cell.textLabel?.text = chatRooms[indexPath.row].name.capitalized
    cell.accessoryType = .disclosureIndicator
    return cell
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
