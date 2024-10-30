//
//  ChatScreenView.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import SwiftUI

struct ChatScreenView: View {
  @ObservedObject var viewModel: ChatViewModel
  @ObservedObject var speechRecognizer = SpeechRecognizer()
  @State private var isAnimating = false
  @State private var isTextEditedManually = false
  @State private var manualText = ""
  @ObservedObject var textVoiceOver = TextVoiceOver()
  @State private var selectedLanguage: Language = .ru

  enum Language: String {
    case ru = "ru"
    case en = "en"
  }
  
  var body: some View {
      VStack {
        Text("\(viewModel.interlocutorUser.login)")
          .font(.title)
          .foregroundColor(.white) // Цвет текста
          .padding()
        
        Spacer()
        
        ScrollView {
          VStack {
            ForEach($viewModel.messages, id: \.id) { $message in
              HStack {
                if message.sender == UserInfo.login {
                  Spacer()
                  let messageText = message.languageFrom == selectedLanguage.rawValue ? message.content : message.translatedMessage
                  Text(messageText)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .onTapGesture(count: 2) {
                      textVoiceOver.speak(text: messageText, localeIdentifier: selectedLanguage.rawValue == "ru" ? .russian : .english)
                    }
                } else {
                  let messageText = message.languageFrom == selectedLanguage.rawValue ? message.content : message.translatedMessage
                  Text(messageText)
                    .padding()
                    .background(Color.gray.opacity(0.5)) // Увеличил прозрачность для лучшего контраста
                    .foregroundColor(.white) // Цвет текста
                    .cornerRadius(10)
                    .onTapGesture(count: 2) {
                      textVoiceOver.speak(text: messageText, localeIdentifier: selectedLanguage.rawValue == "ru" ? .russian : .english)
                    }
                  Spacer()
                }
              }
              .padding(.horizontal) // Отступы между сообщениями
            }
          }
        }
        .onAppear {
          viewModel.loadMessages()
        }

        VStack {
          ScrollViewReader { proxy in
            ScrollView {
              VStack {
                ZStack(alignment: .topLeading) {
                  // Основной фон для TextEditor
                  RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))

                  TextEditor(text: $speechRecognizer.recognizedText)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .id("RecognizedText")
                    .background(Color.clear) // Прозрачный фон внутри TextEditor
                    .cornerRadius(10)
                    .scrollContentBackground(.hidden) // Убираем системный фон
                    .onChange(of: speechRecognizer.recognizedText) { _ in
                      if !isTextEditedManually {
                        withAnimation {
                          proxy.scrollTo("RecognizedText", anchor: .bottom)
                        }
                      }
                    }
                    .onTapGesture {
                      isTextEditedManually = true
                    }
                }
              }
            }
            .frame(height: 100)
          }
          
          HStack {
            Button(action: {
              if self.speechRecognizer.isRunning {
                self.speechRecognizer.stop()
                let newMessage = MessageModel(
                  chatID: viewModel.chatID.uuidString,
                  sender: UserInfo.login ?? "",
                  recipient: viewModel.interlocutorUser.login,
                  content: speechRecognizer.recognizedText,
                  isSentByCurrentUser: true,
                  languageFrom: "ru",
                  languageTo: "en",
                  translatedMessage: speechRecognizer.recognizedText,
                  time: Date().timeIntervalSince1970,
                  audioURL: nil
                )
                viewModel.messages.append(newMessage)
                viewModel.sendMessageForTranslate(message: newMessage.content) { message in
                  //
                }
                speechRecognizer.recognizedText = ""
              } else {
                self.speechRecognizer.start()
              }
            }) {
              Image(systemName: self.speechRecognizer.isRunning ? "stop.fill" : "play.fill")
                .font(.system(size: 24))
                .padding()
                .background(self.speechRecognizer.isRunning ? Color.red : Color.green)
                .foregroundColor(.white)
                .clipShape(Circle())
            }
            .padding()
            
            Button(action: {
              if viewModel.isRecording {
                viewModel.stopRecording(chatID: "defaultChatID", sender: "user1", recipient: "user2", languageFrom: "ru", languageTo: "en")
              } else {
                viewModel.startRecording()
              }
            }) {
              Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                .font(.system(size: 24))
                .padding()
                .background(viewModel.isRecording ? Color.red : Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .onAppear {
                  if viewModel.isRecording {
                    withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                      isAnimating = true
                    }
                  } else {
                    isAnimating = false
                  }
                }
            }
            .padding()
            
            Button(action: {
              // Действие для звонка
            }) {
              Image(systemName: "phone.fill")
                .font(.system(size: 24))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
            }
            .padding()
          }
      
          Picker("Выбор языка", selection: $selectedLanguage) {
            Text("RU").tag(Language.ru)
              .foregroundColor(selectedLanguage == .ru ? .white : .black)
            Text("EN").tag(Language.en)
              .foregroundColor(selectedLanguage == .en ? .white : .black)
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding(0) // Убираем отступы
          .frame(width: 120) // Устанавливаем фиксированную ширину
          .background(Color.gray.opacity(0.7)) // Фон для Picker
          .cornerRadius(10) // Скругленные углы
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .padding()
      .background(Color.black) // Темный фон для всего экрана
      .edgesIgnoringSafeArea(.bottom) // Игнорировать безопасные области снизу
    }
}
