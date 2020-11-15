import Foundation
import ArgumentParser
import SwiftShell
import struct SchemeClient.SchemeClient

struct Add: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Add a todo to a list"
  )

  @Option(name: .shortAndLong, help: "The list to add to, see 'show-lists' for names")
  var list: String?

  @Argument(
    parsing: .remaining,
    help: "The todos title"
  )
  var title: [String]

  @Flag()
  var completed: Bool = false

  @Flag()
  var info: Bool = false

  @Option(
    name: .shortAndLong,
    help: "The date the todo is due"
  )
  var when: String?

  @Option(
    name: .shortAndLong,
    help: "The checklist for the todo",
    transform: { input in
      input.split(separator: ",")
        .map(String.init)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
  )
  var checklist: [String]?

  @Option(
    name: .shortAndLong,
    help: "Additional todo notes"
  )
  var notes: String?

  @Option(
    name: .shortAndLong,
    help: "The tags associated with to the todo",
    transform: { input in
      input.split(separator: ",")
        .map(String.init)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
  )
  var tags: [String]?

  func run() {
    Current.logger.setInfoActive(info)

    let todo = Todo(
      attributes: Todo.Attributes(
        title: self.title.joined(separator: " "),
        when: when,
        list: list,
        tags: tags,
        completed: completed,
        checklistItems: checklist?.map {
          ChecklistItem(attributes: ChecklistItem.Attributes(title: $0))
        }
      )
    )
    do {
      try Current.thingsClient.addTodo(todo).get()
      Current.logger.print("Added todo.")
    } catch {
      Current.logger.print(error.localizedDescription)
    }
  }
}

private struct Show: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Print the todos on the given list")

  @Flag()
  var info: Bool = false

  @Argument(
    help: "The list to todos items from, see 'show-lists' for possible values")
  var projectOrListName: String

  @Flag(name: .shortAndLong, help: "Show todos in a project")
  var project = false

  @Flag(name: .shortAndLong, help: "Show todos in a things list")
  var list = false

  func run() {
    Current.logger.setInfoActive(info)

    do {
      let todos: [String]
      if list {
        todos = try Current.thingsClient.listTodos(inList: projectOrListName).get()
      } else {
        todos = try Current.thingsClient.listTodos(inProject: projectOrListName).get()
      }

      if todos.isEmpty {
        Current.logger.wrap(["\(list ? "List" : "Project") \"\(projectOrListName)\" is empty."])
        return
      }

      Current.logger.wrap(todos)
    } catch {
      Current.logger.error(error.localizedDescription)
    }
  }
}

private struct ShowLists: ParsableCommand {
  public static let configuration = CommandConfiguration(
    abstract: "Print the name of lists to pass to other commands"
  )

  public func run() {
    do {
      let lists = try Current.thingsClient.lists().get()
      Current.logger.wrap(lists)
    } catch {
      Current.logger.error(error.localizedDescription)
    }
  }
}

private struct ShowProjects: ParsableCommand {
  public static let configuration = CommandConfiguration(
    abstract: "Print the name of projects to pass to other commands"
  )

  @Flag()
  var info: Bool = false

  public func run() {
    Current.logger.setInfoActive(info)

    do {
      let projects = try Current.thingsClient.projects().get()
      Current.logger.wrap(projects)
    } catch {
      Current.logger.error(error.localizedDescription)
    }
  }
}

public struct CLI: ParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "things",
    abstract: "Interact with Things3 from the command line",
    subcommands: [
      Add.self,
      Show.self,
      ShowLists.self,
      ShowProjects.self
    ]
  )

  public init() {}
}
