import MacroTester
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(AutoRegisterableMacros)
    import AutoRegisterableMacros

    let testMacros: [String: Macro.Type] = [
        "AutoRegisterable": AutoRegisterableMacro.self,
    ]

    final class AutoRegisterableTests: XCTestCase {
        func testAutoRegisterableInAppService() throws {
            testMacro(macros: testMacros)
        }

        func testAutoRegisterableInFMSServiceProduction() throws {
            testMacro(macros: testMacros)
        }
    }
#endif
