internal import MacroHelper
public import SwiftDiagnostics
public import SwiftSyntax
public import SwiftSyntaxMacros

public struct AutoRegisterableMacro: MemberMacro {
  public enum MacroDiagnostic: String, DiagnosticMessage {
    case requiresStructOrClass = "#AutoRegisterable requires a struct or class"
    case requiresDependencies =
      "#AutoRegisterable requires a property using a type called \"Dependencies\""
    case requiresTypedDependencies =
      "#AutoRegisterable requires explicit type annotations on Dependencies properties"

    public var message: String { rawValue }

    public var diagnosticID: MessageID {
      MessageID(domain: "AutoRegisterable", id: rawValue)
    }

    public var severity: DiagnosticSeverity { .error }
  }

  public static func expansion(
    of attribute: SwiftSyntax.AttributeSyntax,
    providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard let objectName = declaration.classOrStructName else {
      let diagnostic = Diagnostic(
        node: Syntax(attribute), message: MacroDiagnostic.requiresStructOrClass)
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    guard
      let members = declaration.classOrStructMemberBlock?.members
    else {
      let diagnostic = Diagnostic(
        node: Syntax(attribute), message: MacroDiagnostic.requiresStructOrClass)
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    guard
      let dependencyMembers =
        members
        .compactMap({ $0.decl.as(StructDeclSyntax.self) })
        .first(where: { $0.name.text == "Dependencies" })
    else {
      let diagnostic = Diagnostic(
        node: Syntax(attribute), message: MacroDiagnostic.requiresDependencies)
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    let patternBindings = dependencyMembers
      .memberBlock.members
      .compactMap {
        $0.decl.as(VariableDeclSyntax.self)?
          .bindings
          .compactMap { $0 }
      }

    guard
      patternBindings
        .reduce([], +)
        .allSatisfy { $0.typeAnnotation != nil }
    else {
      let diagnostic = Diagnostic(
        node: Syntax(attribute), message: MacroDiagnostic.requiresTypedDependencies)
      context.diagnose(diagnostic)
      throw DiagnosticsError(diagnostics: [diagnostic])
    }

    let parametersString =
      patternBindings.compactMap {
        $0.compactMap {
          (String($0.pattern.description), String($0.typeAnnotation!.type.description))
        }
      }
      .reduce([], +)
      .map { $0 + (": \($1)? = nil") }
      .joined(separator: ",\n  ")

    let dependencyNames = patternBindings.compactMap {
      $0.compactMap { String($0.pattern.description) }
    }
    .reduce([], +)

    let dependenciesString =
      dependencyNames.map { $0 + (": \($0) ?? (try! container.resolve())") }
      .joined(separator: ",\n        ")

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
      )
    ]
  }
}
