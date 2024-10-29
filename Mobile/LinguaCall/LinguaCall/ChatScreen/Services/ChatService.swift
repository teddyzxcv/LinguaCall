//
//  ChatService.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 28.10.2024.
//

import Foundation

class ChatService {
  private var settings: DebugSettings
  
  init(settings: DebugSettings) {
    self.settings = settings
  }
  
  func loadMessages(chatID: UUID, completion: @escaping (Result<[MessageModel], AuthError>) -> Void) {
      guard let url = URL(string: "\(settings.baseURL)/chat/history/\(chatID.uuidString)") else {
        completion(.failure(.invalidURL))
        return
      }
      
      URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
          completion(.failure(.requestFailed(error.localizedDescription)))
          return
        }
        
        guard let data = data else {
          completion(.failure(.unknownError))
          return
        }
        
        do {
          let serverMessages = try JSONDecoder().decode([ServerMessage].self, from: data)
          let messages = serverMessages.compactMap { serverMessage -> MessageModel? in
            guard let time = Double(serverMessage.time) else {
              print("Ошибка преобразования времени из строки в Double")
              return nil
            }
            
            return MessageModel(
              id: UUID(uuidString: serverMessage.id) ?? UUID(),
              chatID: serverMessage.chatID,
              sender: serverMessage.sender,
              recipient: serverMessage.recipient,
              content: serverMessage.message,
              isSentByCurrentUser: serverMessage.sender == chatID.uuidString,
              languageFrom: serverMessage.languageFrom,
              languageTo: serverMessage.languageTo,
              translatedMessage: serverMessage.translatedMessage,
              time: time
            )
          }
          completion(.success(messages))
        } catch {
          print("Ошибка декодирования: \(error)")
          completion(.failure(.decodingError))
        }
      }.resume()
    }
  
  func translateTextMessage(chatID: String, sender: String, recipient: String, message: String, languageFrom: String, languageTo: String, completion: @escaping (Result<MessageModel, Error>) -> Void) {
    guard let url = URL(string: "\(settings.baseURL)/chat/translate") else {
      completion(.failure(AuthError.invalidURL))
      return
    }
    
    let body: [String: Any] = [
      "chatId": chatID,
      "sender": sender,
      "recipient": recipient,
      "message": message,
      "languageTo": languageTo,
      "languageFrom": languageFrom,
      "time": Double(Date().timeIntervalSince1970)
    ]
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
      completion(.failure(AuthError.unknownError))
      return
    }
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(AuthError.requestFailed(error.localizedDescription)))
        return
      }
      
      guard let data = data else {
        completion(.failure(AuthError.unknownError))
        return
      }
      
      do {
        let translatedMessage = try JSONDecoder().decode(ServerMessage.self, from: data)
        let messageModel = MessageModel(
          id: UUID(uuidString: translatedMessage.id) ?? UUID(),
          chatID: translatedMessage.chatID,
          sender: translatedMessage.sender,
          recipient: translatedMessage.recipient,
          content: translatedMessage.message,
          isSentByCurrentUser: translatedMessage.sender == sender,
          languageFrom: translatedMessage.languageFrom,
          languageTo: translatedMessage.languageTo,
          translatedMessage: translatedMessage.translatedMessage,
          time: Double(translatedMessage.time)!
        )
        completion(.success(messageModel))
      } catch {
        completion(.failure(AuthError.decodingError))
      }
    }.resume()
  }
}

// MARK: - ServerMessage Model
struct ServerMessage: Codable {
  let id: String
  let chatID: String
  let sender: String
  let recipient: String
  let message: String
  let languageFrom: String
  let languageTo: String
  let translatedMessage: String
  let time: String  // Время как строка

  enum CodingKeys: String, CodingKey {
    case id
    case chatID = "chatId"         // Соответствует "chatId" в JSON
    case sender
    case recipient
    case message
    case languageFrom
    case languageTo
    case translatedMessage
    case time
  }
}
