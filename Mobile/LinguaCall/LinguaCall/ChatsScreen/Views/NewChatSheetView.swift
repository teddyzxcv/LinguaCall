//
//  NewChatSheetView.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 20.10.2024.
//

import SwiftUI

struct NewChatSheetView: View {
  @Binding var userLoginToFind: String
  @Binding var isUserFound: Bool?
  var onFindUser: (String) -> Void
  
  var body: some View {
    VStack {
      Spacer()
      
      TextField("Введите логин пользователя", text: $userLoginToFind)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
      
      if let isUserFound = isUserFound {
        Text(isUserFound ? "Пользователь найден" : "Пользователь не найден")
          .foregroundColor(isUserFound ? .green : .red)
          .padding(.bottom, 20)
      }
      
      Spacer()
      
      Button(action: {
        onFindUser(userLoginToFind)
      }) {
        Text("Найти")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
          .padding(.horizontal)
      }
    }
    .padding()
  }
}
