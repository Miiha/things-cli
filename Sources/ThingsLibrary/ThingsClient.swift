import Foundation

struct ThingsClient {
  var addTodo: (Todo) -> Result<Void, Error>
  var lists: () -> Result<[String], Error>
  var listTodos: (String, String) -> Result<[String], Error>
  var projects: () -> Result<[String], Error>
}

extension ThingsClient {
  func listTodos(inList list: String) -> Result<[String], Error> {
    self.listTodos(list, "list")
  }

  func listTodos(inProject project: String) -> Result<[String], Error> {
    self.listTodos(project, "project")
  }
}
