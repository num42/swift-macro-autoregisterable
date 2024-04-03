@attached(member, names: arbitrary)
public macro AutoRegisterable() = #externalMacro(
  module: "AutoRegisterableMacros",
  type: "AutoRegisterableMacro"
)
