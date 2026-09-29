@attached(member, names: named(register))
public macro AutoRegisterable() =
  #externalMacro(
    module: "AutoRegisterableMacros",
    type: "AutoRegisterableMacro"
  )
