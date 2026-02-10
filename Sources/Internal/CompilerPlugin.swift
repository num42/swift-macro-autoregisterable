internal import SwiftCompilerPlugin
internal import SwiftSyntaxMacros

@main
struct AutoRegisterablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    AutoRegisterableMacro.self
  ]
}
