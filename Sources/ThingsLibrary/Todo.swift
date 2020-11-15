//
//  File.swift
//  
//
//  Created by Michael Kao on 21.11.20.
//

import Foundation

struct Todo: Encodable, Equatable {
  var type: String = "to-do"
  var attributes: Attributes

  struct Attributes: Encodable, Equatable {
    var title: String?
    var when: String?
    var list: String?
    var tags: [String]?
    var completed: Bool = false
    var checklistItems: [ChecklistItem]?

    enum CodingKeys: String, CodingKey {
      case title
      case when
      case list
      case tags
      case completed
      case checklistItems = "checklist-items"
    }

    struct ChecklistItem: Encodable, Equatable {
      var type: String = "checklist-item"
      var attributes: Attributes

      struct Attributes: Encodable, Equatable {
        var title: String
      }
    }
  }
}

typealias ChecklistItem = Todo.Attributes.ChecklistItem
