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
              Text(chat.lastMessage ?? "Empty Last Message")
                .font(.subheadline)
                .foregroundColor(.gray)
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            logOut()
          }) {
            Image(systemName: "arrow.backward.circle")
              .font(.title2)
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            viewModel.isShowingNewChatSheet = true
          }) {
            Image(systemName: "square.and.pencil")
              .font(.title2)
          }
        }
      }
      .onAppear {
        viewModel.loadChats(userLogin: UserInfo.login ?? "123")
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
