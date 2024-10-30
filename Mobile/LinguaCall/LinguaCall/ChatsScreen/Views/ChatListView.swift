//
//  ChatListView.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 20.10.2024.
//

import SwiftUI
import CoreData

struct ChatListView: View {
  @StateObject private var viewModel: ChatListViewModel
  @State private var userLoginToFind: String = ""
  @State private var isUserFound: Bool? = nil
  @Environment(\.presentationMode) private var presentationMode

  init(context: NSManagedObjectContext) {
    let repository = ChatRepositoryService(context: context)
    _viewModel = StateObject(wrappedValue: ChatListViewModel(chatRepositoryService: repository))
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color.black.ignoresSafeArea() // Фон экрана
        List {
          ForEach(self.viewModel.chats, id: \.self) { chat in
            NavigationLink(
              destination: ChatScreenView(
                viewModel:
                  ChatViewModel(
                    interlocutorUser: User(login: chat.interlocutorLogin ?? "Empty chat.interlocutorLogin"),
                    chatID: chat.id ?? UUID(),
                    settings: DebugSettings()
                  )
              )
            ) {
              VStack(alignment: .leading) {
                Text(chat.interlocutorLogin ?? "Empty Locutor Login")
                  .font(.headline)
                  .foregroundColor(.white)
                Text(chat.lastMessage ?? "Empty Last Message")
                  .font(.subheadline)
                  .foregroundColor(.gray)
              }
              .padding(.vertical, 8) // Отступы сверху и снизу внутри ячейки
              .padding(.leading) // Отступ слева внутри ячейки
            }
            .padding(.trailing) // Отступ справа после стрелки
            .background(Color.black) // Фон ячейки
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1) // Обводка вокруг всей ячейки и стрелки
            )
            .padding(.vertical, 6) // Минимальный отступ между ячейками
            .padding(.horizontal, 8) // Отступ от краев экрана
            .listRowBackground(Color.black) // Цвет фона для строки
            .listRowInsets(EdgeInsets()) // Убираем внутренние отступы, чтобы ячейки растянулись на всю ширину
          }

        }
        .scrollContentBackground(.hidden) // Убираем стандартный фон списка
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Chats")
        .foregroundColor(.white)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              logOut()
            }) {
              Image(systemName: "arrow.backward.circle")
                .font(.title2)
                .foregroundColor(.white)
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              viewModel.isShowingNewChatSheet = true
            }) {
              Image(systemName: "square.and.pencil")
                .font(.title2)
                .foregroundColor(.white)
            }
          }
        }
        .onAppear {
          viewModel.loadChats(userLogin: UserInfo.login ?? "123")
        }
      }
    }
    .sheet(isPresented: $viewModel.isShowingNewChatSheet) {
      NewChatSheetView(userLoginToFind: $userLoginToFind, isUserFound: $isUserFound) { interlocutorLogin in
        viewModel.authService.checkIfUserExists(interlocutorLogin: interlocutorLogin) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let userFound):
              isUserFound = userFound
              if userFound {
                viewModel.addChat(interlocutorLogin: interlocutorLogin)
                viewModel.isShowingNewChatSheet = false
              }
            case .failure(let error):
              print("Error: \(error)")
              isUserFound = false
            }
          }
        }
      }
    }
  }

  private func logOut() {
    UserInfo.login = nil
    UserInfo.password = nil
    presentationMode.wrappedValue.dismiss()
  }
}
