//
//  ProgrammerAssertions.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 20/03/2017.
//
//

import Foundation

/// drop-in replacements

public func assert(_ condition: @autoclosure () -> Bool,
                   _ message: @autoclosure () -> String = "",
                   file: StaticString = #file,
                   line: UInt = #line) {
  Assertions.assertClosure(condition(), message(), file, line)
}

public func assertionFailure(_ message: @autoclosure () -> String = "",
                             file: StaticString = #file,
                             line: UInt = #line) {
  Assertions.assertionFailureClosure(message(), file, line)
}

public func precondition(_ condition: @autoclosure () -> Bool,
                         _ message: @autoclosure () -> String = "",
                         file: StaticString = #file,
                         line: UInt = #line) {
  Assertions.preconditionClosure(condition(), message(), file, line)
}

public func preconditionFailure(_ message: @autoclosure () -> String = "",
                                file: StaticString = #file,
                                line: UInt = #line) -> Never {
  Assertions.preconditionFailureClosure(message(), file, line)
}

public func fatalError(_ message: @autoclosure () -> String = "",
                       file: StaticString = #file,
                       line: UInt = #line) -> Never {
  Assertions.fatalErrorClosure(message(), file, line)
}

/// Stores custom assertions closures, by default it points to Swift functions. But test target can override them.
open class Assertions {
  public static var assertClosure = swiftAssertClosure
  public static var assertionFailureClosure = swiftAssertionFailureClosure
  public static var preconditionClosure = swiftPreconditionClosure
  public static var preconditionFailureClosure = swiftPreconditionFailureClosure
  public static var fatalErrorClosure = swiftFatalErrorClosure

  public static let swiftAssertClosure = { Swift.assert($0, $1, file: $2, line: $3) }
  public static let swiftAssertionFailureClosure = { Swift.assertionFailure($0, file: $1, line: $2) }
  public static let swiftPreconditionClosure = { Swift.precondition($0, $1, file: $2, line: $3) }
  public static let swiftPreconditionFailureClosure = { Swift.preconditionFailure($0, file: $1, line: $2) }
  public static let swiftFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
}

/// This is a `noreturn` function that runs forever and doesn't return.
/// Used by assertions with `@noreturn`.
private func runForever() -> Never {
  repeat {
    RunLoop.current.run()
  } while (true)
}
