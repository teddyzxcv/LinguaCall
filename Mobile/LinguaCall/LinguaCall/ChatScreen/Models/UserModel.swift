//
//  UserModel.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import Foundation

class User {
  var id: UUID
  var login: String
  
  init(login: String) {
    self.id = UUID() 
    self.login = login
  }
}
