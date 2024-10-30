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
  let authService = AuthService(settings: DebugSettings())
  
  init(chatRepositoryService: ChatRepositoryService) {
    self.chatRepositoryService = chatRepositoryService
  }
  
  func loadChats(userLogin: String) {
    //    chatRepositoryService.deleteAllChats()
    DispatchQueue.global(qos: .userInitiated).async {
      let fetchedChats = self.chatRepositoryService.getChats(userLogin: userLogin)
      DispatchQueue.main.async {
        self.chats = fetchedChats
        print("Loaded chats for user \(userLogin): \(self.chats.map { $0.title ?? "" })") // Логирование
      }
    }
  }
  
  func addChat(interlocutorLogin: String) {
      // Попытка получить chatId с первым порядком логинов
      fetchChatId(login1: UserInfo.login ?? "LOGIN NOT FOUND", login2: interlocutorLogin) { [weak self] chatId in
          if let chatId = chatId {
              // Чат найден, сохраняем
              self?.saveExistingChat(existingChatId: chatId, interlocutorLogin: interlocutorLogin)
          } else {
              // Чат не найден, пробуем в обратном порядке
              self?.fetchChatId(login1: interlocutorLogin, login2: UserInfo.login ?? "LOGIN NOT FOUND") { [weak self] reversedChatId in
                  if let reversedChatId = reversedChatId {
                      // Чат найден в обратном порядке логинов, сохраняем
                      self?.saveExistingChat(existingChatId: reversedChatId, interlocutorLogin: interlocutorLogin)
                  } else {
                      // Чат не найден в обоих порядках, создаем новый
                      self?.createNewChat(interlocutorLogin: interlocutorLogin)
                  }
              }
          }
      }
  }

  // Вспомогательный метод для получения chatId
  private func fetchChatId(login1: String, login2: String, completion: @escaping (String?) -> Void) {
      authService.getChatId(login1: login1, login2: login2) { result in
          switch result {
          case .success(let chatId):
              if chatId == "Chat not found" {
                  completion(nil)
              } else {
                  completion(chatId)
              }
          case .failure(let error):
              print("Error fetching chat ID: \(error)")
              completion(nil)
          }
      }
  }
  
  private func saveExistingChat(existingChatId: String, interlocutorLogin: String) {
    DispatchQueue.main.async {
      let context = self.chatRepositoryService.context
      let existingChat = ChatModel(context: context)
      existingChat.id = UUID(uuidString: existingChatId)
      existingChat.title = interlocutorLogin
      existingChat.interlocutorLogin = interlocutorLogin
      existingChat.userLogin = UserInfo.login
      existingChat.lastMessage = "Tap to open dialog! 😉"
      
      do {
        try context.save()
        print("Existing chat loaded for user \(String(describing: UserInfo.login)): \(existingChat.title ?? "")")
        self.loadChats(userLogin: UserInfo.login ?? "123") // Deleted!!!
      } catch {
        print("Error saving existing chat: \(error)")
      }
    }
  }
  
  private func createNewChat(interlocutorLogin: String) {
    DispatchQueue.main.async {
      let context = self.chatRepositoryService.context
      let newChat = ChatModel(context: context)
      newChat.id = UUID()
      newChat.title = interlocutorLogin
      newChat.interlocutorLogin = interlocutorLogin
      newChat.userLogin = UserInfo.login
      newChat.lastMessage = "Tap to open dialog! 😉"
      
      do {
        try context.save()
        print("New chat created for user \(String(describing: UserInfo.login)): \(newChat.title ?? "")")
        self.loadChats(userLogin: UserInfo.login ?? "123") // Deleted!!!
      } catch {
        print("Error saving new chat: \(error)")
      }
    }
  }
}

