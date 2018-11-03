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

//  let cookies = List<ChatCookie>()

  convenience init(accountName: String, id: Int, browserCookies: [HTTPCookie]) {
    self.init()

    self.id = id
    name = accountName

//    for cookie in browserCookies {
//      let cookieObject = ChatCookie(browserCookie: cookie)
//      cookies.append(cookieObject)
//    }
  }
}


//final class ChatCookie: Object {
//  @objc dynamic var cookie: HTTPCookie!
//
//  convenience init(browserCookie: HTTPCookie) {
//    self.init()
//
//    cookie = browserCookie
//  }
//}
