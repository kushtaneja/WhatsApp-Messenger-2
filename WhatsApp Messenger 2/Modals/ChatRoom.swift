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
  @objc dynamic var cookies: [HTTPCookie]!


  convenience init(accountName: String, browserCookies: [HTTPCookie]) {
    self.init()

    name = accountName
    cookies = browserCookies
  }
}
