import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(AutoRegisterableMacros)
  import AutoRegisterableMacros

  let testMacros: [String: Macro.Type] = [
    "AutoRegisterable": AutoRegisterableMacro.self
  ]

  @Suite
  struct AutoRegisterableMacroTests {
    @Test func autoRegisterableInAppService() {
      MacroTester.testMacro(macros: testMacros)
    }

    @Test func autoRegisterableInFMSServiceProduction() {
      MacroTester.testMacro(macros: testMacros)
    }

    @Test func structWithoutDependencyEntries() {
      MacroTester.testMacro(macros: testMacros)
    }
  }
#endif
