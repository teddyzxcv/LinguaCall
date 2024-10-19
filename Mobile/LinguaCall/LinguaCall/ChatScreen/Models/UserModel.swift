//
//  UserModel.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import Foundation

class User {
  var id: UUID
  var name: String
  
  init(name: String) {
    self.id = UUID() 
    self.name = name
  }
}
