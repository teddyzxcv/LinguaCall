//
//  ChatRepositoryService.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 20.10.2024.
//

import SwiftUI
import CoreData

class ChatRepositoryService {
  let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func getChats(userLogin: String) -> [ChatModel] {
    let fetchRequest = ChatModel.fetchRequest() as! NSFetchRequest<ChatModel>
    fetchRequest.predicate = NSPredicate(format: "userLogin == %@", userLogin)
    
    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Ошибка получения чатов: \(error)")
      return []
    }
  }
  
  func createChat(interlocutorLogin: String) {
    let newChat = ChatModel(context: context)
    newChat.userLogin = UserInfo.login
    newChat.interlocutorLogin = interlocutorLogin
    
    do {
      try context.save()
    } catch {
      print("Error saving new chat: \(error)")
    }
  }
  
  func deleteAllChats() {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ChatModel.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
      try context.execute(deleteRequest)
      try context.save()
      print("All chats have been deleted.")
    } catch {
      print("Failed to delete all chats: \(error)")
    }
  }
}

