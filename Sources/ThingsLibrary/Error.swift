import Foundation

public enum Error: Swift.Error, LocalizedError, Equatable {
  case script(ScriptError)
  case underlying(Swift.Error)
  case string(String)

  static let unknown = Error.string("An unknown error occured.")

  public var errorDescription: String? {
    switch self {
    case let .script(error):
      return error.localizedDescription
    case let .underlying(error):
      return error.localizedDescription
    case let .string(value):
      return value
    }
  }

  public static func == (lhs: Error, rhs: Error) -> Bool {
    switch (lhs, rhs) {
    case let (.script(lhs), .script(rhs)):
      return lhs == rhs
    case let (.underlying(lhs), .underlying(rhs)):
      return lhs as NSError == rhs as NSError
    case let (.string(lhs), .string(rhs)):
      return lhs == rhs
    case (.script, _), (.underlying, _), (.string, _):
      return false
    }
  }
}

public struct ScriptError: LocalizedError, Equatable {
  public var briefMessage: String
  public var message: String
  public var errorNumber: Int
  public var range: NSRange

  public init(briefMessage: String, message: String, errorNumber: Int, range: NSRange) {
    self.briefMessage = briefMessage
    self.message = message
    self.errorNumber = errorNumber
    self.range = range
  }

  public var errorDescription: String? {
    briefMessage
  }
}

extension Error {
  public init(dictionary: NSDictionary) {
    guard let briefMessage = dictionary["NSAppleScriptErrorBriefMessage"] as? String,
          let message = dictionary["NSAppleScriptErrorMessage"] as? String,
          let errorNumber = dictionary["NSAppleScriptErrorNumber"] as? NSNumber,
          let range = dictionary["NSAppleScriptErrorRange"] as? NSValue
    else {
      self = .unknown
      return
    }

    self = .script(
      ScriptError(
        briefMessage: briefMessage,
        message: message,
        errorNumber: errorNumber.intValue,
        range: range.rangeValue
      )
    )
  }
}
