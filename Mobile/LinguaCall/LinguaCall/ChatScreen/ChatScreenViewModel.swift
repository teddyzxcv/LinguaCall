//
//  ChatScreenViewModel.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import Combine
import SwiftUI
import SwiftData

class ChatViewModel: ObservableObject {
  @Published var user: User
  @Published var messages: [MessageModel] = []
  @Published var isCalling: Bool = false
  
  init(user: User) {
    self.user = user
    loadUser()
    loadMessages()
  }
  
  func loadUser() {
    
  }
  
  func saveUserName() {
    
  }
  
  func loadMessages() {
    messages = [
      MessageModel(content: "Привет!", isSentByCurrentUser: false),
      MessageModel(content: "Привет, как дела?", isSentByCurrentUser: true),
      MessageModel(content: "Все отлично, а у тебя?", isSentByCurrentUser: false)
    ]
  }
  
  func startCall() {
    isCalling = true
  }
  
  func endCall() {
    isCalling = false
  }
}


