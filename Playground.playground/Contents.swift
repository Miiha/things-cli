import Foundation
import ThingsLibrary


let source = """
tell application "Things3"
  set collected_projects to {}
  repeat with pr in projects
    copy name of pr to end of collected_projects
  end repeat

  return collected_projects
end tell
"""

let script = NSAppleScript(source: source)
print(source)
var error: NSDictionary?
let result = script?.executeAndReturnError(&error)
print(result)
if let projects = result?.coerce(toDescriptorType: typeAEList) {
  let items = (0..<projects.numberOfItems)
    .compactMap { projects.atIndex($0 + 1)?.stringValue }
  print(items)
}
print(error)

