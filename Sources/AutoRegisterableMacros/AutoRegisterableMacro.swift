import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoRegisterableMacro: MemberMacro {
    public enum MacroError: Error, CustomStringConvertible {
        case requiresStructOrClass
        case requiresDependencies

        public var description: String {
            switch self {
            case .requiresStructOrClass:
                "#AutoRegisterable requires a struct or class"
            case .requiresDependencies:
                "#AutoRegisterable requires a property using a type called \"Dependencies\""
            }
        }
    }

    public static func expansion(
        of _: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in _: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let objectName = declaration.as(ClassDeclSyntax.self)?.name.description
            ?? declaration.as(StructDeclSyntax.self)?.name.description
        else {
            throw MacroError.requiresStructOrClass
        }

        guard let members = (
            declaration
                .as(ClassDeclSyntax.self)?
                .memberBlock
                ?? declaration.as(StructDeclSyntax.self)?
                .memberBlock
        )?
            .members
        else {
            throw MacroError.requiresStructOrClass
        }

        guard let dependencyMembers = members
            .compactMap({ $0.decl.as(StructDeclSyntax.self) })
            .first(where: { $0.name.text == "Dependencies" })
        else {
            throw MacroError.requiresDependencies
        }

        let patternBindings = dependencyMembers
            .memberBlock.members
            .compactMap {
                $0.decl.as(VariableDeclSyntax.self)?
                    .bindings
                    .compactMap { $0 }
            }

        let parametersString =
            patternBindings.compactMap { $0.compactMap { (String($0.pattern.description), String($0.typeAnnotation!.type.description)) } }
                .reduce([], +)
                .map { $0.appending(": \($1)? = nil") }
                .joined(separator: ",\n")
                .indentedBy("  ")

        let dependencyNames = patternBindings.compactMap { $0.compactMap { String($0.pattern.description) } }
            .reduce([], +)

        let dependenciesString =
            dependencyNames.map { $0.appending(": \($0) ?? (try! container.resolve())") }
                .joined(separator: ",\n")
                .indentedBy("        ")

        return [
            DeclSyntax(
                extendedGraphemeClusterLiteral: """
                public static func register<TargetType>(
                  in container: DependencyContainer,
                  scope: ComponentScope = .shared,
                  as type: TargetType.Type = \(objectName).self\(dependencyNames.isEmpty ? "" : ",")
                  \(parametersString)
                ) {
                  container.register(scope) {
                    \(objectName)(
                      dependencies: \(objectName).Dependencies(
                        \(dependenciesString)
                      )
                    )  as! TargetType
                  }
                }
                """
            ),
        ]
    }
}

@main
struct AutoRegisterablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutoRegisterableMacro.self,
    ]
}

extension String {
    func indentedBy(_ indentation: String) -> String {
        split(separator: "\n").joined(separator: "\n" + indentation)
    }
}
