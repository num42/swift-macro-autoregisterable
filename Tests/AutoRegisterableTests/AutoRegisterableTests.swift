import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(AutoRegisterableMacros)
    import AutoRegisterableMacros

    final class AutoRegisterableTests: XCTestCase {
        let testMacros: [String: Macro.Type] = [
            "AutoRegisterable": AutoRegisterableMacro.self,
        ]

        func testAutoRegisterableInAppService() throws {
            testMacro(macros: testMacros)
        }

        func testAutoRegisterableInFMSServiceProduction() throws {
            testMacro(macros: testMacros)
        }
    }
#endif
