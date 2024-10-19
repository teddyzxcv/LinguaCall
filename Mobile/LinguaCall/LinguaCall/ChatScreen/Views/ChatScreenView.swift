//
//  ChatScreenView.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import SwiftUI

struct ChatScreenView: View {
  @ObservedObject var viewModel: ChatViewModel
  @Environment(\.modelContext) var context
  
  var body: some View {
    VStack {
      TextField("Имя пользователя", text: $viewModel.user.name, onCommit: {
        viewModel.saveUserName()
      })
      .font(.title)
      .padding()  // Одинаковый отступ
      .background(Color.gray.opacity(0.1))
      .cornerRadius(8)
      
      ScrollView {
        VStack {
          ForEach(viewModel.messages) { message in
            HStack {
              if message.isSentByCurrentUser {
                Spacer()
                Text(message.content)
                  .padding()
                  .background(Color.blue)
                  .foregroundColor(.white)
                  .cornerRadius(10)
              } else {
                Text(message.content)
                  .padding()
                  .background(Color.gray.opacity(0.2))
                  .cornerRadius(10)
                Spacer()
              }
            }
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
    .padding()
  }
}
