//
//  MessageModel.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import Foundation

struct MessageModel: Identifiable, Hashable {
  let id: UUID
  let chatID: String
  let sender: String
  let recipient: String
  let content: String
  let isSentByCurrentUser: Bool
  let languageFrom: String
  let languageTo: String
  let translatedMessage: String
  let time: TimeInterval
  let audioURL: URL?
  
  init(id: UUID = UUID(),
       chatID: String,
       sender: String,
       recipient: String,
       content: String,
       isSentByCurrentUser: Bool,
       languageFrom: String,
       languageTo: String,
       translatedMessage: String,
       time: Double,
       audioURL: URL? = nil) {
    self.id = id
    self.chatID = chatID
    self.sender = sender
    self.recipient = recipient
    self.content = content
    self.isSentByCurrentUser = isSentByCurrentUser
    self.languageFrom = languageFrom
    self.languageTo = languageTo
    self.translatedMessage = translatedMessage
    self.time = time
    self.audioURL = audioURL
  }
}
