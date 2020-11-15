//
//  File.swift
//  
//
//  Created by Michael Kao on 22.11.20.
//

import Foundation

public struct Environment {
  var appleScript: AppleScript
  var thingsClient: ThingsClient
  var logger: Logger
}

private let logger = Logger.live
private let appleScript = AppleScript.live(logger: logger)

var Current = Environment(
  appleScript: appleScript,
  thingsClient: .live(
    appleScript: appleScript,
    logger: logger,
    schemeClient: .live
  ),
  logger: logger
)
