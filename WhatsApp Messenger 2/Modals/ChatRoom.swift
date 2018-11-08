//
//  ChatRoom.swift
//  WhatsApp Messenger 2
//
//  Created by Kush Taneja on 03/11/18.
//  Copyright © 2018 Kush Taneja. All rights reserved.
//

import RealmSwift

final class ChatRoom: Object {
  @objc dynamic var name: String!
  @objc dynamic var id = 0

  override class func primaryKey() -> String? {
    return "id"
  }

  let cookies = List<ChatCookie>()

  convenience init(accountName: String, id: Int, browserCookies: [HTTPCookie]) {
    self.init()

    self.id = id
    name = accountName

    for cookie in browserCookies {
      let cookieObject = ChatCookie(browserCookie: cookie)
      cookies.append(cookieObject)
    }
  }

  func saveCookies(browserCookies: [HTTPCookie]){
    let realm = try! Realm()

    try! realm.write {
      cookies.removeAll()

      for cookie in browserCookies {
        let cookieObject = ChatCookie(browserCookie: cookie)
        cookies.append(cookieObject)
        print("saved: " + cookie.name + "with count \(browserCookies.count) and saved \(cookies.count)");
      }
    }
  }
}

final class ChatCookie: Object {
  @objc dynamic var cookieValue: String!
  @objc dynamic var cookieName: String!
  @objc dynamic var created: Date!
  @objc dynamic var domain: String!
  @objc dynamic var version = 1


  convenience init(browserCookie: HTTPCookie) {
    self.init()

    cookieValue = browserCookie.value
    cookieName = browserCookie.name
    domain = browserCookie.domain
    version = browserCookie.version

    if let createdValue = browserCookie.properties?[HTTPCookiePropertyKey.init(rawValue: "Created")] as? TimeInterval {
      created = Date.init(timeIntervalSinceReferenceDate: createdValue)
    } else {
      created = Date()
    }
  }
}

