import Foundation
import XCTest
import SchemeClient
@testable import ThingsLibrary

class CLITests: XCTestCase {

  func testAdd() throws {
    var addedTodos: [Todo] = []
    Current.thingsClient.addTodo = { addedTodos.append($0); return .success(()) }
    let arguments = [
      "Fixture", "Title", "--when" ,"tomorrow", "--list", "Fixture-List", "--checklist", "item-1, item-2", "--tags", "tag-1, tag-2"
    ]

    let add = try Add.parse(arguments)

    add.run()

    XCTAssertEqual(add.title, ["Fixture", "Title"])
    XCTAssertEqual(
      addedTodos,
      [
        Todo(
          attributes: Todo.Attributes(
            title: "Fixture Title",
            when: "tomorrow",
            list: "Fixture-List",
            tags: ["tag-1", "tag-2"],
            completed: false,
            checklistItems: [
              ChecklistItem(attributes: ChecklistItem.Attributes(title: "item-1")),
              ChecklistItem(attributes: ChecklistItem.Attributes(title: "item-2"))
            ]
          )
        )
      ]
    )
  }

  func testSuccessfulAddOuput() throws {
    var printed: [String] = []
    Current.logger.print = { printed.append($0) }
    Current.thingsClient.addTodo = { _ in .success(()) }

    let add = try Add.parse(["Fixture"])
    add.run()

    XCTAssertEqual(printed, ["Added todo."])
  }

  func testFailedAddOuput() throws {
    var printed: [String] = []
    Current.logger.print = { printed.append($0) }
    Current.thingsClient.addTodo = { _ in .failure(.unknown) }

    let add = try Add.parse(["Fixture"])
    add.run()

    XCTAssertEqual(printed, ["An unknown error occured."])
  }
}
