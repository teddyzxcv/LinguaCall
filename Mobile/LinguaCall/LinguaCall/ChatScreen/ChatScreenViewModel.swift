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
  @Published var user: User
  @Published var messages: [MessageModel] = []
  @Published var isCalling: Bool = false
  @Published var isRecording: Bool = false
  
  var audioRecorder: AVAudioRecorder?
  var audioPlayer: AVPlayer?
  var recordedAudioURL: URL?
  
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
  
  func stopRecording() {
    audioRecorder?.stop()
    isRecording = false
    recordedAudioURL = audioRecorder?.url
    if let url = recordedAudioURL {
      addAudioMessage(url: url)
    }
  }
  
  func addAudioMessage(url: URL) {
    let audioMessage = MessageModel(content: "Аудиосообщение", isSentByCurrentUser: true, audioURL: url)
    messages.append(audioMessage)
  }
  
  func finishRecording(success: Bool) {
    audioRecorder?.stop()
    isRecording = false

    if success {
      let audioURL = audioRecorder?.url
      let newMessage = MessageModel(content: "Голосовое сообщение", isSentByCurrentUser: true, audioURL: audioURL)
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




