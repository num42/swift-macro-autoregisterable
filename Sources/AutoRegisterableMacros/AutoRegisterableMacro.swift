import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoRegisterableMacro: MemberMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    let className = declaration.as(ClassDeclSyntax.self)?.name.description ?? declaration.as(StructDeclSyntax.self)!.name.description

      let members = (
        declaration
            .as(ClassDeclSyntax.self)?
            .memberBlock
            ?? declaration.as(StructDeclSyntax.self)!
            .memberBlock
      )
          .members

    let dependencyMembers = members
      .compactMap {
        $0.decl.as(StructDeclSyntax.self)
      }
      .first {
        $0.name.text == "Dependencies"
      }!
      .memberBlock.members
      
      let patternBindings = dependencyMembers.compactMap {
          $0.decl.as(VariableDeclSyntax.self)?
        .bindings
        .compactMap { $0 }
      }

    let parametersString =
      patternBindings.compactMap { $0.compactMap { (String($0.pattern.description), String($0.typeAnnotation!.type.description))  } }
      .reduce([], +)
          .map {
        $0.appending(": \($1)? = nil")
      }
      .joined(separator: ",\n")
      .indentedBy("  ")
      
      let dependencyNames = patternBindings.compactMap { $0.compactMap { String($0.pattern.description) } }
      .reduce([], +)
      
    let dependenciesString =
      dependencyNames.map {
        $0.appending(": \($0) ?? (try! container.resolve())")
      }
      .joined(separator: ",\n")
      .indentedBy("        ")

    return [
      DeclSyntax(
        extendedGraphemeClusterLiteral: """
        public static func register<TargetType>(
          in container: DependencyContainer,
          scope: ComponentScope = .shared,
          as type: TargetType.Type = \(className).self,
          \(parametersString)
        ) {
          container.register(scope) {
            \(className)(
              dependencies: \(className).Dependencies(
                \(dependenciesString)
              )
            )  as! TargetType
          }
        }
        """
      )
    ]
  }
}

@main
struct AutoRegisterablePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    AutoRegisterableMacro.self
  ]
}

extension String {
  func indentedBy(_ indentation: String) -> String {
    split(separator: "\n").joined(separator: "\n" + indentation)
  }
}
