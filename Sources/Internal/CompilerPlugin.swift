import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AutoRegisterablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    AutoRegisterableMacro.self
  ]
}
