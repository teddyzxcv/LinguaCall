//
//  ChatScreenViewModel.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import Combine
import SwiftUI
import AVFoundation

class ChatViewModel: ObservableObject {
  @Published var chatID: UUID
  @Published var interlocutorUser: User
  @Published var interlocutorLanguage: String = "en" // mocked
  @Published var messages: [MessageModel] = []
  @Published var isCalling: Bool = false
  @Published var isRecording: Bool = false
  
  private var chatService: ChatService
  var audioRecorder: AVAudioRecorder?
  var audioPlayer: AVPlayer?
  var recordedAudioURL: URL?
  
  init(interlocutorUser: User, chatID: UUID, settings: DebugSettings) {
    self.chatID = chatID
    self.interlocutorUser = interlocutorUser
    self.chatService = ChatService(settings: settings)
  }
  
  func loadMessages() {
    chatService.loadMessages(chatID: self.chatID) { [weak self] result in
      DispatchQueue.main.async {
        switch result {
        case .success(let messages):
          self?.messages = messages
        case .failure(let error):
          print("Ошибка загрузки сообщений: \(error)")
        }
      }
    }
  }
  
  func sendMessageForTranslate(message: String, completion: @escaping (Result<MessageModel, Error>) -> Void) {
    chatService.translateTextMessage(
      chatID: chatID.uuidString,
      sender: UserInfo.login ?? "Empty user login", // bad
      recipient: interlocutorUser.login,
      message: message,
      languageFrom: "ru", // mocked
      languageTo: interlocutorLanguage,
      completion: completion
    )
  }
  
  func startRecording() {
    let audioSession = AVAudioSession.sharedInstance()
    
    do {
      try audioSession.setCategory(.playAndRecord, mode: .default)
      try audioSession.setActive(true)
      audioSession.requestRecordPermission { allowed in
        DispatchQueue.main.async {
          if allowed {
            self.startRecordingSession()
          } else {
            print("Запись невозможна, нет доступа к микрофону.")
          }
        }
      }
    } catch {
      print("Ошибка настройки аудиосессии: \(error.localizedDescription)")
    }
  }
  
  func startRecordingSession() {
    let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
    let settings = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 12000,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
      audioRecorder?.record()
      isRecording = true
    } catch {
      print("Ошибка начала записи: \(error.localizedDescription)")
    }
  }
  
  func stopRecording(chatID: String, sender: String, recipient: String, languageFrom: String, languageTo: String) {
    audioRecorder?.stop()
    isRecording = false
    recordedAudioURL = audioRecorder?.url
    
    if let url = recordedAudioURL {
//      addAudioMessage(
//        url: url,
//        chatID: chatID,
//        sender: sender,
//        recipient: recipient,
//        languageFrom: languageFrom,
//        languageTo: languageTo
//      )
    }
  }
  
  func addAudioMessage(url: URL, chatID: String, sender: String, recipient: String, languageFrom: String, languageTo: String) {
    let audioMessage = MessageModel(
      chatID: chatID,
      sender: sender,
      recipient: recipient,
      content: "Аудиосообщение",
      isSentByCurrentUser: true,
      languageFrom: languageFrom,
      languageTo: languageTo,
      translatedMessage: "", // Можно оставить пустым, если перевода нет
      time: Date().timeIntervalSince1970, // Текущее время
      audioURL: url
    )
    messages.append(audioMessage)
  }
  
  func finishRecording(success: Bool, chatID: String, sender: String, recipient: String, languageFrom: String, languageTo: String) {
    audioRecorder?.stop()
    isRecording = false
    
    if success, let audioURL = audioRecorder?.url {
      let newMessage = MessageModel(
        chatID: chatID,
        sender: sender,
        recipient: recipient,
        content: "Голосовое сообщение",
        isSentByCurrentUser: true,
        languageFrom: languageFrom,
        languageTo: languageTo,
        translatedMessage: "",
        time: Date().timeIntervalSince1970,
        audioURL: audioURL
      )
      messages.append(newMessage)
    } else {
      print("Запись не удалась")
    }
  }
  
  func playAudio(from url: URL) {
    do {
      audioPlayer = try AVPlayer(url: url)
      audioPlayer?.play()
    } catch {
      print("Не удалось воспроизвести аудио: \(error.localizedDescription)")
    }
  }
  
  private func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}




