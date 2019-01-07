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
  @objc dynamic var localStorageDump: String?

  convenience init(accountName: String, id: Int) {
    self.init()

    self.id = id
    name = accountName
  }
}
