import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(AutoRegisterableMacros)
  import AutoRegisterableMacros

  final class AutoRegisterableDiagnosticsTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
      "AutoRegisterable": AutoRegisterableMacro.self
    ]

    func testEnumThrowsError() throws {
      assertMacroExpansion(
        """
        @AutoRegisterable
        enum AnEnum {}
        """,
        expandedSource: """
          enum AnEnum {}
          """,
        diagnostics: [
          .init(
            message: AutoRegisterableMacro.MacroError.requiresStructOrClass.description,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros
      )
    }

    func testStructHasNoDependencies() throws {
      assertMacroExpansion(
        """
        @AutoRegisterable
        struct AStruct {}
        """,
        expandedSource: """
          struct AStruct {}
          """,
        diagnostics: [
          .init(
            message: AutoRegisterableMacro.MacroError.requiresDependencies.description,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros
      )
    }
  }
#endif
