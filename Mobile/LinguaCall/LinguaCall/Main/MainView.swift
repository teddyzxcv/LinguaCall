//
//  MainView.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 19.10.2024.
//

import SwiftUI

struct MainView: View {
  @State private var showDebugMenu = false
  @ObservedObject var settings = DebugSettings()
  @State private var user: User? = User(login: "Sergey")
  @Environment(\.managedObjectContext) private var viewContext
  
  var body: some View {
    ZStack(alignment: .leading) {
      NavigationView {
        LoginView(settings: settings)
      }
      
      VStack {
        Spacer()
        Spacer()
        HStack {
          Button(action: {
            showDebugMenu.toggle()
          }) {
            Text("D")
              .fontWeight(.bold)
              .frame(width: 40, height: 40)
              .background(Color.gray.opacity(0.7))
              .foregroundColor(.white)
              .cornerRadius(5)
          }
          Spacer()
        }
        Spacer()
      }
      .edgesIgnoringSafeArea(.all)
      .navigationBarTitle("Main Screen", displayMode: .inline)
      .sheet(isPresented: $showDebugMenu) {
        DebugMenuView(settings: settings)
      }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
