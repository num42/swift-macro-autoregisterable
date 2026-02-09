import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(AutoRegisterableMacros)
  import AutoRegisterableMacros

  @Suite struct AutoRegisterableDiagnosticsTests {
    let testMacros: [String: Macro.Type] = [
      "AutoRegisterable": AutoRegisterableMacro.self
    ]

    @Test func enumThrowsError() {
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
            message: AutoRegisterableMacro.MacroDiagnostic.requiresStructOrClass.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros
      )
    }

    @Test func structHasNoDependencies() {
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
            message: AutoRegisterableMacro.MacroDiagnostic.requiresDependencies.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros
      )
    }

    @Test func dependenciesMustBeTyped() {
      assertMacroExpansion(
        """
        @AutoRegisterable
        struct AStruct {
          struct Dependencies {
            let service = Service()
          }
        }
        """,
        expandedSource: """
          struct AStruct {
            struct Dependencies {
              let service = Service()
            }
          }
          """,
        diagnostics: [
          .init(
            message: AutoRegisterableMacro.MacroDiagnostic.requiresTypedDependencies.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros
      )
    }
  }
#endif
