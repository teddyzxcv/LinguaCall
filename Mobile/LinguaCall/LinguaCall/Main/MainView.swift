//
//  MainView.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import SwiftUI

struct MainView: View {
  @StateObject var viewModel = ChatViewModel(user: User(name: "Pan"))
  
  var body: some View {
    NavigationView {
      ChatScreenView(viewModel: viewModel)
    }
  }
}
