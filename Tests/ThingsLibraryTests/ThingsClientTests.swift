import Foundation
import XCTest
import SchemeClient
@testable import ThingsLibrary

class ThingsClientTests: XCTestCase {

  func testAddSuccess() throws {
    let client = ThingsClient.mock(addTodo: { _ in .success(()) })
    try client.addTodo(Todo(attributes: Todo.Attributes(title: "Foo"))).get()
  }

  func testAddFailure() throws {
    let client = ThingsClient.mock(addTodo: { _ in .failure(Error.unknown) })
    let result = client.addTodo(Todo(attributes: Todo.Attributes(title: "Foo")))
    XCTAssertEqual(result.error, .unknown)
  }

  func testAdd() throws {
    var scheme: String?
    let schemeClient = SchemeClient.mock(
      run: {
        scheme = $0.removingPercentEncoding
        return .success("")
      }
    )
    let client = ThingsClient.live(appleScript: .mock(), logger: .empty, schemeClient: schemeClient)

    let todo = Todo(
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
    _ = client.addTodo(todo)

    XCTAssertEqual(scheme, "things:///json?data=[{\"type\":\"to-do\",\"attributes\":{\"tags\":[\"tag-1\",\"tag-2\"],\"title\":\"FixtureTitle\",\"when\":\"tomorrow\",\"list\":\"Fixture-List\",\"completed\":false,\"checklist-items\":[{\"type\":\"checklist-item\",\"attributes\":{\"title\":\"item-1\"}},{\"type\":\"checklist-item\",\"attributes\":{\"title\":\"item-2\"}}]}}]")
  }

  func testShowProjects() throws {
    var script: String?
    let appleScript = AppleScript(run: {
      script = $0
      return .success(nil)
    })

    let client = ThingsClient.live(appleScript: appleScript, logger: .empty, schemeClient: .mock())
    _ = client.projects()
    XCTAssertEqual(
      script,
      """
      tell application "Things3"
        set collected_projects to {}
        repeat with pr in projects
          copy name of pr to end of collected_projects
        end repeat
        return collected_projects
      end
      """
    )
  }

  func testTodosInList() throws {
    var script: String?
    let appleScript = AppleScript(run: {
      script = $0
      return .success(nil)
    })

    let client = ThingsClient.live(appleScript: appleScript, logger: .empty, schemeClient: .mock())
    _ = client.listTodos(inList: "Inbox")
    XCTAssertEqual(
      script,
      """
      tell application "Things3"
        set collected_todos to {}
        repeat with toDo in to dos of list "Inbox"
          copy name of toDo to end of collected_todos
        end repeat
        return collected_todos
      end
      """
    )
  }
  func testTodosInProject() throws {
    var script: String?
    let appleScript = AppleScript(run: {
      script = $0
      return .success(nil)
    })

    let client = ThingsClient.live(appleScript: appleScript, logger: .empty, schemeClient: .mock())
    _ = client.listTodos(inProject: "Fixture-Project")
    XCTAssertEqual(
      script,
      """
      tell application "Things3"
        set collected_todos to {}
        repeat with toDo in to dos of project "Fixture-Project"
          copy name of toDo to end of collected_todos
        end repeat
        return collected_todos
      end
      """
    )
  }

}

extension Result {
  var error: Failure? {
    guard case let .failure(error) = self else { return nil }
    return error
  }
}
