//
//  UserInfo.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 28.10.2024.
//

import Foundation

final class UserInfo {
  static let shared = UserInfo()
  private init() {}
  
  static var id: UUID?
  static var login: String?
  static var password: String?
}
