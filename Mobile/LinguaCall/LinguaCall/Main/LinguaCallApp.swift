//
//  LinguaCallApp.swift
//  LinguaCall
//
//  Created by Zhengwu Pan on 14.10.2024.
//

import SwiftUI

@main
struct lingua_callApp: App {
  let persistenceController = CoreDataStack.shared

  var body: some Scene {
    WindowGroup {
      MainView()
        .environment(\.managedObjectContext, persistenceController.context)
    }
  }
}
