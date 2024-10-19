//
//  MessageModel.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import Foundation

struct MessageModel: Identifiable {
  let id = UUID()
  let content: String
  let isSentByCurrentUser: Bool
  let audioURL: URL?
  
  init(content: String, isSentByCurrentUser: Bool, audioURL: URL? = nil) {
    self.content = content
    self.isSentByCurrentUser = isSentByCurrentUser
    self.audioURL = audioURL
  }
}
