//
//  ChatScreenView.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import SwiftUI

struct ChatScreenView: View {
  @ObservedObject var viewModel: ChatViewModel
  @State private var isAnimating = false
  
  var body: some View {
    VStack {
      TextField("Имя пользователя", text: $viewModel.user.name, onCommit: {
        viewModel.saveUserName()
      })
      .font(.title)
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(8)
      
      ScrollView {
        VStack {
          ForEach(viewModel.messages) { message in
            HStack {
              if message.isSentByCurrentUser {
                Spacer()
                if let audioURL = message.audioURL {
                  HStack {
                    Button(action: {
                      viewModel.playAudio(from: audioURL)
                    }) {
                      Image(systemName: "play.circle.fill")
                        .font(.system(size: 18))
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
    
                    Text("Голосовое сообщение")
                      .foregroundColor(.white)
                  }
                  .padding()
                  .background(Color.blue)
                  .cornerRadius(10)
                } else {
                  Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
              } else {
                if let audioURL = message.audioURL {
                  HStack {
                    Button(action: {
                      viewModel.playAudio(from: audioURL)
                    }) {
                      Image(systemName: "play.circle.fill")
                        .font(.system(size: 18))
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }

                    Text("Голосовое сообщение")
                      .foregroundColor(.black)
                  }
                  .padding()
                  .background(Color.gray.opacity(0.2))
                  .cornerRadius(10)
                } else {
                  Text(message.content)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                Spacer()
              }
            }
          }
        }
      }
      
      HStack {
        Button(action: {
          if viewModel.isRecording {
            viewModel.stopRecording()
          } else {
            viewModel.startRecording()
          }
        }) {
          Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.fill")
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
          viewModel.startCall()
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
    }
    .padding()
  }
}

