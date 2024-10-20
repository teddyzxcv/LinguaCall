//
//  ChatListViewModel.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 20.10.2024.
//

import SwiftUI
import CoreData

class ChatListViewModel: ObservableObject {
  @Published var chats: [ChatModel] = []
  @Published var isShowingNewChatSheet = false
  private let chatRepositoryService: ChatRepositoryService
  
  init(chatRepositoryService: ChatRepositoryService) {
    self.chatRepositoryService = chatRepositoryService
  }
  
  func loadChats(userLogin: String) {
    DispatchQueue.global(qos: .userInitiated).async {
      let fetchedChats = self.chatRepositoryService.getChats(userLogin: userLogin)
      DispatchQueue.main.async {
        self.chats = fetchedChats
        print("Loaded chats for user \(userLogin): \(self.chats.map { $0.title ?? "" })") // Логирование
      }
    }
  }
  
  func addChat(interlocutorLogin: String) {
    let newChat = ChatModel(context: chatRepositoryService.context)
    newChat.id = UUID()
    newChat.title = interlocutorLogin
    newChat.interlocutorLogin = interlocutorLogin
    newChat.userLogin = UserInfo.login
    newChat.lastMessage = "Start dialog! 😉"
    
    do {
      try chatRepositoryService.context.save()
      print("New chat saved for user \(String(describing: UserInfo.login)): \(newChat.title ?? "")")
      loadChats(userLogin: UserInfo.login ?? "123") // Deleted!!!
    } catch {
      print("Error saving new chat: \(error)")
    }
  }
}

