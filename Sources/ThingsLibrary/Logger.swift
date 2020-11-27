import Foundation

struct Logger {
  var info: (String) -> Void
  var print: (String) -> Void
  var setInfoActive: (Bool) -> Void
}

extension Logger {
  func wrap(_ lines: @autoclosure () -> [String]) {
    self.print("--------------------")
    lines().forEach(self.print)
    self.print("--------------------")
  }

  func success(_ value: String) {
    self.wrap([value])
  }

  func error(_ value: String) {
    self.wrap([value])
  }
}

private var isInfoActive = false

extension Logger {
  static let live = Logger(
    info: { isInfoActive ? Swift.print("[Info] \($0)") : () },
    print: { Swift.print($0) },
    setInfoActive: { isInfoActive = $0 }
  )
}
