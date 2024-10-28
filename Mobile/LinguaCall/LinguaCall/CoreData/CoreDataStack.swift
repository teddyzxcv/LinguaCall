//
//  CoreDataStack.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 23.10.2024.
//

import CoreData

class CoreDataStack {
  static let shared = CoreDataStack()
  private init() {}
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreDataFile")
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Ошибка инициализации Core Data: \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
}

