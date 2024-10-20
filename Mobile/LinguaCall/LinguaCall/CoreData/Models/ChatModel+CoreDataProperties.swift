//
//  ChatModel+CoreDataProperties.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 23.10.2024.
//
//

import Foundation
import CoreData

public class ChatModel: NSManagedObject {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatModel> {
    return NSFetchRequest<ChatModel>(entityName: "ChatModel")
  }
  
  @NSManaged public var id: UUID?
  @NSManaged public var lastMessage: String?
  @NSManaged public var title: String?
  @NSManaged public var userLogin: String?
  @NSManaged public var interlocutorLogin: String?
}

extension ChatModel : Identifiable {}
