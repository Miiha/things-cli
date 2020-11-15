//
//  File.swift
//  
//
//  Created by Michael Kao on 15.11.20.
//

import Foundation

public struct AppleScript {
  public var run: (String) -> Result<NSAppleEventDescriptor?, Error>
}

extension AppleScript {
  static func live(logger: Logger) -> Self {
    AppleScript(
      run: { source in
        logger.info("AppleScript:\n\(source)")

        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        if let error = error.map(Error.init(dictionary:)) {
          return .failure(error)
        }

        return .success(result)
      }
    )
  }
}
