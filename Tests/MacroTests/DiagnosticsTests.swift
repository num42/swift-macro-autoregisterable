internal import MacroTestHelper
internal import SwiftSyntaxMacrosGenericTestSupport
internal import Testing

#if canImport(AutoRegisterableMacros)
  import AutoRegisterableMacros

  @Suite
  struct AutoRegisterableDiagnosticsTests {
    @Test func enumThrowsError() {
      MacroTestHelper.assertMacroExpansion(
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
      MacroTestHelper.assertMacroExpansion(
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
      MacroTestHelper.assertMacroExpansion(
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
