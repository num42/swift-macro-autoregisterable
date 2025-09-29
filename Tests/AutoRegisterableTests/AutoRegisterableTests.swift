import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(AutoRegisterableMacros)
    import AutoRegisterableMacros

    @Suite struct AutoRegisterableTests {
        let testMacros: [String: Macro.Type] = [
            "AutoRegisterable": AutoRegisterableMacro.self,
        ]

        @Test func autoRegisterableInAppService() {
            testMacro(macros: testMacros)
        }

        @Test func autoRegisterableInFMSServiceProduction() {
            testMacro(macros: testMacros)
        }

        @Test func structWithoutDependencyEntries() {
            testMacro(macros: testMacros)
        }
    }
#endif
