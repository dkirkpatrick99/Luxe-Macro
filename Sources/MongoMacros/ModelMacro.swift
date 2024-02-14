/* -----------------------------------------------------------
 * :: :  G  H  O  S  T  :                                   ::
 * -----------------------------------------------------------
 * @wabistudios :: cosmos :: realms
 *
 * CREDITS.
 *
 * T.Furby              @furby-tm       <devs@wabi.foundation>
 * D.Kirkpatrick  @dkirkpatrick99  <d.kirkpatrick99@gmail.com>
 *
 *         Copyright (C) 2023 Wabi Animation Studios, Ltd. Co.
 *                                        All Rights Reserved.
 * -----------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ----------------------------------------------------------- */

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum VendingMachineError: Error {
  case insufficientFunds(message: String)
}


public struct MongoModelMacro: MemberMacro, ExtensionMacro, MemberAttributeMacro
{
  public static func expansion(of _: SwiftSyntax.AttributeSyntax,
                               attachedTo _: some SwiftSyntax.DeclGroupSyntax,
                               providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                               conformingTo _: [SwiftSyntax.TypeSyntax],
                               in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax]
  {
    #if !os(Linux)
      return []
    #else
      let decl: DeclSyntax = """
      extension \(type.trimmed): Fluent.Model
      {
        public typealias IDValue = MongoID

        public static var schema: String = \"\(type.trimmed)\"
      }
      """

      let enc: DeclSyntax = """
      extension \(type.trimmed): Encodable
      {}
      """

      let dec: DeclSyntax = """
      extension \(type.trimmed): Decodable
      {}
      """

      let fields: DeclSyntax = """
      extension \(type.trimmed): Fluent.Fields
      {}
      """

      let content: DeclSyntax = """
      extension \(type.trimmed): Content
      {}
      """

      guard let extensionDecl = decl.as(ExtensionDeclSyntax.self),
            let encodableDecl = enc.as(ExtensionDeclSyntax.self),
            let decodableDecl = dec.as(ExtensionDeclSyntax.self),
            let fieldsDecl = fields.as(ExtensionDeclSyntax.self),
            let contentDecl = content.as(ExtensionDeclSyntax.self)
      else { return [] }

      return [
        extensionDecl,
        encodableDecl,
        decodableDecl,
        fieldsDecl,
        contentDecl,
      ]
    #endif
  }

  public static func expansion(of _: SwiftSyntax.AttributeSyntax,
                               attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
                               providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
                               in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax]
  {
    let classDecl: ClassDeclSyntax = declaration.cast(ClassDeclSyntax.self)

    #if !os(Linux)
      guard let binding = member.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let type = binding.typeAnnotation?.type
      else { return ["@Field"] }

      print("PRINTING IDENTIFIER: \(identifier)")

      var field: [AttributeSyntax] = ["@Persisted"]

      if "\(type)".contains("LinkingObjects")
      {
          let ofName = "\(classDecl.name)".lowercased()
          field = ["@Persisted(originProperty: \"\(raw: ofName)\")"]
        
      }
    #else /* !os(Linux) */
      guard let binding = member.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let type = binding.typeAnnotation?.type
      else { return ["@Field"] }

      var field = [AttributeSyntax]()

      if "\(type)".contains("Date")
      {
        field = ["@TimestampProperty<\(classDecl.name), DefaultTimestampFormat>(key: \"\(identifier)\", on: .create, format: .default)"]
      }
      else if "\(type)".contains("?")
      {
        field = ["@OptionalField(key: \"\(identifier)\")"]
      }
      else
      {
        field = ["@Field(key: \"\(identifier)\")"]
      }

    #endif /* os(Linux) */

    return field
  }

  public static func expansion(of _: SwiftSyntax.AttributeSyntax,
                               providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                               in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
  {
    let classDecl: ClassDeclSyntax = declaration.cast(ClassDeclSyntax.self)
    let ctorID = "id: MongoID? = nil,"

    let ctorFields: [String] = [ctorID] + classDecl.memberBlock.members.compactMap
    { ctor in
      guard let binding = ctor.decl.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let type = binding.typeAnnotation?.type
      else { return "" }

      var result = ""
      let fuckingComma = classDecl.memberBlock.members.last == ctor ? "" : ","

      if classDecl.memberBlock.members.last == ctor
      {
        result += "            "
        result += "\(identifier): \(type) = .init()"
      }
      else
      {
        result += "            "
        result += "\(identifier): \(type) = .init()\(fuckingComma)"
      }

      if "\(type)".contains("AssetCategory")
      {
        result = "            "
        result += "\(identifier): \(type) = .featured\(fuckingComma)"
      }

      if "\(type)".contains("GiftCardAPI")
      {
        result = "            "
        result += "\(identifier): \(type) = .tango\(fuckingComma)"
      }

      if "\(type)".contains("BrandCategory")
      {
        result = "            "
        result += "\(identifier): \(type) = .tech\(fuckingComma)"
      }

      if "\(type)".contains("IntegrationAPIs")
      {
        result = "            "
        result += "\(identifier): \(type) = .entrata\(fuckingComma)"
      }

      if "\(type)".contains("PointsType")
      {
        result = "            "
        result += "\(identifier): \(type) = .resident(.unknown)\(fuckingComma)"
      }

      if "\(type)".contains("UserRole")
      {
        result = "            "
        result += "\(identifier): \(type) = .resident\(fuckingComma)"
      }

      if "\(type)".contains("PostType")
      {
        result = "            "
        result += "\(identifier): \(type) = .resident(.post)\(fuckingComma)"
      }

      if "\(type)".contains("LinkingObjects")
      {
        #if !os(Linux)
          let ofName = "\(classDecl.name)".lowercased()
          let fromType = "\(type)"
            .replacingOccurrences(of: "LinkingObjects<", with: "")
            .replacingOccurrences(of: ">", with: "")
          result += "            "
          result = result.replacingOccurrences(of: ".init()", with: ".init(fromType: \(fromType).self, property: \"\(ofName)\")")
        #endif /* !os(Linux) */
      }

      if "\(type)".contains("?")
      {
        result = "            "
        result += "\(identifier): \(type) = nil\(fuckingComma)"
      }

      return result
    }

    let ctorDefaults: [String] = classDecl.memberBlock.members.compactMap
    { assign in
      guard let binding = assign.decl.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
      else { return "" }

      var result = ""

      if let type = binding.typeAnnotation?.type
      {
        if "\(type)".contains("AssetCategory")
        {
          result += "self.\(identifier) = .featured"
          return result
        }

        if "\(type)".contains("GiftCardAPI")
        {
          result += "self.\(identifier) = .tango"
          return result
        }

        if "\(type)".contains("BrandCategory")
        {
          result += "self.\(identifier) = .tech"
          return result
        }

        if "\(type)".contains("IntegrationAPIs")
        {
          result += "self.\(identifier) = .entrata"
          return result
        }

        if "\(type)".contains("PointsType")
        {
          result += "self.\(identifier) = .resident(.unknown)"
          return result
        }

        if "\(type)".contains("UserRole")
        {
          result += "self.\(identifier) = .resident"
          return result
        }

        if "\(type)".contains("PostType")
        {
          result += "self.\(identifier) = .resident(.post)"
          return result
        }

        if "\(type)".contains("LinkingObjects")
        {
          #if !os(Linux)
            let ofName = "\(classDecl.name)".lowercased()
            let fromType = "\(type)"
              .replacingOccurrences(of: "LinkingObjects<", with: "")
              .replacingOccurrences(of: ">", with: "")

            return "self.\(identifier) = .init(fromType: \(fromType).self, property: \"\(ofName)\")"
          #endif /* !os(Linux) */
        }

        if "\(type)".contains("?")
        {
          result += "self.\(identifier) = nil"
          return result
        }
      }

      return "self.\(identifier) = .init()"
    }

    let ctorAssigns: [String] = classDecl.memberBlock.members.compactMap
    { assign in
      guard let binding = assign.decl.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
      else { return "" }

      return "self.\(identifier) = \(identifier)"
    }

    #if !os(Linux)
      let identity: DeclSyntax = """
      @Persisted(primaryKey: true)
      public var _id: MongoID
      """
      let superCtor: DeclSyntax = """
      super.init()
      """
    #else /* !os(Linux) */
      let identity: DeclSyntax = """
      @ID(custom: .id)
      public var id: MongoID?
      """
      let superCtor: DeclSyntax = """
      """
    #endif /* os(Linux) */

    #if !os(Linux)
      let ctor: DeclSyntax = """
      public override init()
      {
        super.init()
        self.id = nil
      }
      """
    #else /* os(Linux) */
      let ctor: DeclSyntax = """
      public init()
      {
        \(raw: ctorDefaults.joined(separator: "\n"))
      }

      private func updater(_ m: any Fluent.Model, on database: Database) async throws
      {
        try await m.update(on: database)
      }

      public final func update(on database: Database) async throws
      {
        if let ident = self.id
        {
          print(ident)
          self._$idExists = true
          self._$id.value = ident
          try await self.updater(self, on: database)
        }
      }
      """
    #endif /* os(Linux) */

    return [
      identity,
      ctor,
      """
      public init(\(raw: ctorFields.joined(separator: "\n")))
      {
        \(superCtor)
        self.id = id
        if let ident = self.id
        {
          self._$idExists = true
          self._$id.value = ident
        }
        \(raw: ctorAssigns.joined(separator: "\n"))
      }
      """,
    ]
  }
}

























public struct MongoEmbedMacro: MemberMacro, ExtensionMacro, MemberAttributeMacro
{
  public static func expansion(of _: SwiftSyntax.AttributeSyntax,
                               attachedTo _: some SwiftSyntax.DeclGroupSyntax,
                               providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
                               conformingTo _: [SwiftSyntax.TypeSyntax],
                               in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax]
  {
    #if !os(Linux)
      let enc: DeclSyntax = """
      extension \(type.trimmed): Encodable
      {}
      """

      let dec: DeclSyntax = """
      extension \(type.trimmed): Decodable
      {}
      """

      guard let encodableDecl = enc.as(ExtensionDeclSyntax.self),
            let decodableDecl = dec.as(ExtensionDeclSyntax.self)
      else { return [] }

      return [
        encodableDecl,
        decodableDecl,
      ]
    #else /* os(Linux) */
      let enc: DeclSyntax = """
      extension \(type.trimmed): Encodable
      {}
      """

      let dec: DeclSyntax = """
      extension \(type.trimmed): Decodable
      {}
      """

      let content: DeclSyntax = """
      extension \(type.trimmed): Content
      {}
      """

      guard let encodableDecl = enc.as(ExtensionDeclSyntax.self),
            let decodableDecl = dec.as(ExtensionDeclSyntax.self),
            let contentDecl = content.as(ExtensionDeclSyntax.self)
      else { return [] }

      return [
        encodableDecl,
        decodableDecl,
        contentDecl,
      ]
    #endif /* os(Linux) */
  }

  public static func expansion(of _: SwiftSyntax.AttributeSyntax,
                               attachedTo _: some SwiftSyntax.DeclGroupSyntax,
                               providingAttributesFor _: some SwiftSyntax.DeclSyntaxProtocol,
                               in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax]
  {
    #if !os(Linux)
      let field: [AttributeSyntax] = ["@Persisted"]
    #else /* !os(Linux) */
      let field: [AttributeSyntax] = [""]
    #endif /* os(Linux) */

    return field
  }

  public static func expansion(of _: SwiftSyntax.AttributeSyntax,
                               providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                               in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
  {
    let classDecl: ClassDeclSyntax = declaration.cast(ClassDeclSyntax.self)

    let ctorFields: [String] = classDecl.memberBlock.members.compactMap
    { ctor in
      guard let binding = ctor.decl.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
            let type = binding.typeAnnotation?.type
      else { return "" }

      var result = ""
      let fuckingComma = classDecl.memberBlock.members.last == ctor ? "" : ","

      if classDecl.memberBlock.members.last == ctor
      {
        result += "            "
        result += "\(identifier): \(type) = .init()"
      }
      else
      {
        result += "            "
        result += "\(identifier): \(type) = .init()\(fuckingComma)"
      }

      if "\(type)".contains("AssetCategory")
      {
        result = "            "
        result += "\(identifier): \(type) = .featured\(fuckingComma)"
      }

      if "\(type)".contains("GiftCardAPI")
      {
        result = "            "
        result += "\(identifier): \(type) = .tango\(fuckingComma)"
      }

      if "\(type)".contains("BrandCategory")
      {
        result = "            "
        result += "\(identifier): \(type) = .tech\(fuckingComma)"
      }

      if "\(type)".contains("IntegrationAPIs")
      {
        result = "            "
        result += "\(identifier): \(type) = .entrata\(fuckingComma)"
      }

      if "\(type)".contains("PointsType")
      {
        result = "            "
        result += "\(identifier): \(type) = .resident(.unknown)\(fuckingComma)"
      }

      if "\(type)".contains("UserRole")
      {
        result = "            "
        result += "\(identifier): \(type) = .resident\(fuckingComma)"
      }

      if "\(type)".contains("PostType")
      {
        result = "            "
        result += "\(identifier): \(type) = .resident(.post)\(fuckingComma)"
      }

      if "\(type)".contains("LinkingObjects")
      {
        #if !os(Linux)
          let ofName = "\(classDecl.name)".lowercased()
          let fromType = "\(type)"
            .replacingOccurrences(of: "LinkingObjects<", with: "")
            .replacingOccurrences(of: ">", with: "")
          result += "            "
          result = result.replacingOccurrences(of: ".init()", with: ".init(fromType: \(fromType).self, property: \"\(ofName)\")")
        #endif /* !os(Linux) */
      }

      if "\(type)".contains("?")
      {
        result = "            "
        result += "\(identifier): \(type) = nil\(fuckingComma)"
      }

      return result
    }

    let ctorDefaults: [String] = classDecl.memberBlock.members.compactMap
    { assign in
      guard let binding = assign.decl.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
      else { return "" }

      var result = ""

      if let type = binding.typeAnnotation?.type
      {
        if "\(type)".contains("AssetCategory")
        {
          result += "self.\(identifier) = .featured"
          return result
        }

        if "\(type)".contains("GiftCardAPI")
        {
          result += "self.\(identifier) = .tango"
          return result
        }

        if "\(type)".contains("BrandCategory")
        {
          result += "self.\(identifier) = .tech"
          return result
        }

        if "\(type)".contains("IntegrationAPIs")
        {
          result += "self.\(identifier) = .entrata"
          return result
        }

        if "\(type)".contains("PointsType")
        {
          result += "self.\(identifier) = .resident(.unknown)"
          return result
        }

        if "\(type)".contains("UserRole")
        {
          result += "self.\(identifier) = .resident"
          return result
        }

        if "\(type)".contains("PostType")
        {
          result += "self.\(identifier) = .resident(.post)"
          return result
        }

        if "\(type)".contains("LinkingObjects")
        {
          #if !os(Linux)
            let ofName = "\(classDecl.name)".lowercased()
            let fromType = "\(type)"
              .replacingOccurrences(of: "LinkingObjects<", with: "")
              .replacingOccurrences(of: ">", with: "")

            return "self.\(identifier) = .init(fromType: \(fromType).self, property: \"\(ofName)\")"
          #endif /* !os(Linux) */
        }

        if "\(type)".contains("?")
        {
          result += "self.\(identifier) = nil"
          return result
        }
      }

      return "self.\(identifier) = .init()"
    }

    let ctorAssigns: [String] = classDecl.memberBlock.members.compactMap
    { assign in
      guard let binding = assign.decl.as(VariableDeclSyntax.self)?.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
      else { return "" }

      return "self.\(identifier) = \(identifier)"
    }

    #if !os(Linux)
      let ctor: DeclSyntax = """
      public override init()
      {
        super.init()
      }
      """
    #else /* !os(Linux) */
      let ctor: DeclSyntax = """
      public init()
      {}
      """
    #endif /* os(Linux) */

    /*
     * Conformance to codable which is hopefully no longer needed.
     *
     * """
     * public init(from: Decoder) throws
     * {}
     * """,
     * """
     * public func encode(to encoder: Encoder) throws
     * {}
     * """ */

    return [
      ctor,
      """
      public init(\(raw: ctorFields.joined(separator: "\n")))
      {
        \(raw: ctorAssigns.joined(separator: "\n"))
      }
      """,
    ]
  }
}

@main
struct MongoMacrosPlugin: CompilerPlugin
{
  let providingMacros: [Macro.Type] = [
    MongoModelMacro.self,
    MongoEmbedMacro.self,
  ]
}
