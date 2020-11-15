//
//  File.swift
//  
//
//  Created by Michael Kao on 22.11.20.
//

import Foundation
import SchemeClient
@testable import ThingsLibrary

extension AppleScript {
  static func mock(
    run: @escaping (String) -> Result<NSAppleEventDescriptor?, Error> = { _ in _unimplemented("run") }
  ) -> Self {

    Self(
      run: run
    )
  }
}

extension SchemeClient {
  static func mock(
    run: @escaping (String) -> Result<String, Error> = { _ in _unimplemented("run") }
  ) -> Self {

    Self(run: run)
  }
}

extension Logger {
  static func mock(
    info: @escaping (String) -> Void = { _ in _unimplemented("info") },
    print: @escaping (String) -> Void = { _ in _unimplemented("print") },
    setInfoActive: @escaping (Bool) -> Void = { _ in _unimplemented("setInfoActive") }
  ) -> Self {

    Self(
      info: info,
      print: print,
      setInfoActive: setInfoActive
    )
  }
  
  static let empty = Logger(
    info: { _ in },
    print: { _ in },
    setInfoActive: { _ in }
  )
}

extension ThingsClient {
  static func mock(
    addTodo: @escaping (Todo) -> Result<Void, Error> = { _ in _unimplemented("addTodo") },
    lists: @escaping () -> Result<[String], Error> = { _unimplemented("lists") },
    listTodos: @escaping (String, String) -> Result<[String], Error> = { _, _ in _unimplemented("listTodos") },
    projects: @escaping () -> Result<[String], Error> = { _unimplemented("projects") }
  ) -> Self {

    Self(
      addTodo: addTodo,
      lists: lists,
      listTodos: listTodos,
      projects: projects
    )
  }
}

func _unimplemented(
  _ function: StaticString, file: StaticString = #file, line: UInt = #line
) -> Never {

  fatalError(
    """
    `\(function)` was called but is not implemented. Be sure to provide an implementation for
    this endpoint when creating the mock.
    """,
    file: file,
    line: line
  )
}
