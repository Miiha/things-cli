//
//  File.swift
//  
//
//  Created by Michael Kao on 22.11.20.
//

import Foundation
import SchemeClient

extension ThingsClient {
  static func live(
    appleScript: AppleScript,
    logger: Logger,
    schemeClient: SchemeClient
  ) -> ThingsClient {

    ThingsClient(
      addTodo: { todo in
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode([todo])
        let encodedJson = jsonData
          .flatMap { String(data: $0, encoding: .utf8) }
          .map { $0.removingAllWhitespaces() }

        encodedJson.map { logger.info("Encoded todo: \($0)") }

        let escapedJson = encodedJson
          .flatMap { $0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) }

        escapedJson.map { logger.info("Escaped todo: \($0)") }

        guard let json = escapedJson else {
          return .failure(.string("Input data can't be encoded."))
        }

        let urlString = "things:///json?data=\(json)"
        logger.info("URL: \(urlString)")

        return schemeClient.run(urlString)
          .mapError(Error.underlying)
          .flatMap {
            $0.contains("x-things-id")
              ? .success(())
              : .failure(Error.string("Invalid things response."))
          }
      },
      lists: {
        .success(["Inbox", "Today", "Anytime", "Upcoming", "Trash"])
      },
      listTodos: { project, type in
        let content = """
set collected_todos to {}
repeat with toDo in to dos of \(type) "\(project)"
  copy name of toDo to end of collected_todos
end repeat
return collected_todos
"""

        let source = tellApplication(content: content)
        return appleScript.run(source)
          .mapError(Error.underlying)
          .flatMap { $0.map(Result.success) ?? .failure(Error.unknown) }
          .flatMap { value in
            if value.numberOfItems == 0 {
              return .success([])
            }
            if let list = value.list {
              return .success(list.compactMap(\.stringValue))
            }
            return .failure(.unknown)
          }
      },
      projects: {
        let content = """
set collected_projects to {}
repeat with pr in projects
  copy name of pr to end of collected_projects
end repeat

return collected_projects
"""
        let source = tellApplication(content: content)
        return appleScript.run(source)
          .mapError(Error.underlying)
          .flatMap { $0.map(Result.success) ?? .failure(Error.unknown) }
          .flatMap { value in
            if value.numberOfItems == 0 {
              return .success([])
            }
            if let list = value.list {
              return .success(list.compactMap(\.stringValue))
            }
            return .failure(.unknown)
          }
      }
    )
  }
}

private extension NSAppleEventDescriptor {
  var list: NSAppleEventDescriptor? {
    self.coerce(toDescriptorType: typeAEList)
  }

  func compactMap<A>(_ transform: (NSAppleEventDescriptor) -> A?) -> [A] {
    (0..<self.numberOfItems)
      .compactMap { self.atIndex($0 + 1) }
      .compactMap(transform)
  }
}

private func tellApplication(content: String) -> String {
  return
    """
    tell application "Things3"
    \(content.split(separator: "\n").map { "  \($0)" }.joined(separator: "\n"))
    end
    """
}

private extension StringProtocol where Self: RangeReplaceableCollection {
  func removingAllWhitespaces() -> Self {
    filter { !$0.isWhitespace }
  }

  mutating func removeAllWhitespaces() {
    removeAll(where: \.isWhitespace)
  }
}
