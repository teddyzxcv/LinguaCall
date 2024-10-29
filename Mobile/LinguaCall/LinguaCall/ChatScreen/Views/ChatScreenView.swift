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
        .cornerRadius(8)
      
      Spacer()
      
      ScrollView {
        VStack {
          ForEach($viewModel.messages, id: \.id) { $message in
            HStack {
              if message.sender == UserInfo.login {
                Spacer()
                  if message.languageFrom == selectedLanguage.rawValue {
                    Text(message.content)
                      .padding()
                      .background(Color.blue)
                      .foregroundColor(.white)
                      .cornerRadius(10)
                      .onTapGesture(count: 2) {
                        textVoiceOver.speak(text: message.content, localeIdentifier: selectedLanguage.rawValue == "ru" ? .russian : .english)
                      }
                  } else {
                    Text(message.translatedMessage)
                      .padding()
                      .background(Color.blue)
                      .foregroundColor(.white)
                      .cornerRadius(10)
                      .onTapGesture(count: 2) {
                        textVoiceOver.speak(text: message.translatedMessage, localeIdentifier: selectedLanguage.rawValue == "ru" ? .russian : .english)
                      }
                  }
              } else {
                if message.languageFrom == selectedLanguage.rawValue {
                  Text(message.content)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .onTapGesture(count: 2) {
                      textVoiceOver.speak(text: message.content, localeIdentifier: selectedLanguage.rawValue == "ru" ? .russian : .english)
                    }
                } else {
                  Text(message.translatedMessage)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .onTapGesture(count: 2) {
                      textVoiceOver.speak(text: message.translatedMessage, localeIdentifier: selectedLanguage.rawValue == "ru" ? .russian : .english)
                    }
                }
                Spacer()
              }
            }
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
              TextEditor(text: $speechRecognizer.recognizedText)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .id("RecognizedText")
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
                  translatedMessage: speechRecognizer.recognizedText, // wtf
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
            Text("EN").tag(Language.en)
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding(.horizontal)
        }
    }
    .navigationBarTitleDisplayMode(.inline)
    .padding()
  }
}
