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

@_exported import Fluent
@_exported import FluentMongoDriver
@_exported import Foundation
@_exported import MongoKitten
import Vapor

#if !os(Linux)
  @_exported import EventKit
  @_exported import Realm
  @_exported import RealmSwift
#endif /* os(iOS) || os(macOS) || os(xrOS) */

public typealias FluentDB = Fluent.Database

/*
 * We do some preprocessing magic on our aliased types
 * so we can have a single shared API across iOS, Web,
 * Server, (& the only thing that's missing is Android).
 *
 * For now, we define Android models in Kotlin. Eventually,
 * we should expose our models with @_objc and Kotlin can
 * share our same unified Swift API.
 */

// MARK: Darwin conformance for encoding/decoding into BSON.

#if !os(Linux)
  public typealias MongoID = RealmSwift.ObjectId
  public typealias MongoEnum = RealmSwift.PersistableEnum & CaseIterable & Codable & Content
  public typealias MongoList<T: RealmSwift.RealmCollectionValue> = RealmSwift.List<T>
  public typealias MongoRef<T> = T
  public typealias MongoSet<T: RealmSwift.RealmCollectionValue> = RealmSwift.MutableSet<T>
  public typealias MongoMap<K: RealmSwift._MapKey, V: RealmSwift.RealmCollectionValue> = RealmSwift.Map<K, V>
  public typealias UserRef = MongoID
  public typealias PropertyRef = MongoID
  public typealias BrandRef = MongoID
  public typealias PointLogRef = MongoID

  public typealias MongoModeled = RealmSwift.Object & RealmSwift.ObjectKeyIdentifiable & Content
  public typealias MongoEmbedded = RealmSwift.EmbeddedObject & RealmSwift.ObjectKeyIdentifiable & Content

  public typealias Modeled = RealmSwift.Object & RealmSwift.ObjectKeyIdentifiable & Content
  public typealias Embedded = RealmSwift.EmbeddedObject & RealmSwift.ObjectKeyIdentifiable & Codable & Content

  extension MongoID: Fields
  {}

  extension MongoID: Identifiable
  {}

  /**
   * Is necessary to compile on iOS, which makes Realm Objects compatible
   * with Fluent, and does not apply for os's which cannot compile RealmSwift,
   * such as Linux. */
  extension RealmSwift.Object: Fluent.Model
  {
    public typealias ID<Value> = IDProperty<RealmSwift.Object, Value>
      where Value: Codable & Identifiable

    public typealias IDValue = MongoID

    public static var schema: String
    {
      className()
    }
    public var id: MongoID?
    {
      get { value(forKey: "_id") as? MongoID }
      set(newValue)
      {
        #if !os(iOS)
          /* 
           * not intended for iOS, else this causes a crash. */
          setValue(newValue ?? MongoID(), forKey: "_id")
        #endif /* !os(iOS) */
      }
    }
  }

  @attached(member, names: arbitrary)
  @attached(memberAttribute)
  @attached(extension, conformances: Modeled, names: named(_id), arbitrary)
  public macro MongoModel() = #externalMacro(module: "MongoMacros", type: "MongoModelMacro")

  @attached(member, names: arbitrary)
  @attached(memberAttribute)
  @attached(extension, conformances: Embedded, names: arbitrary)
  public macro MongoEmbed() = #externalMacro(module: "MongoMacros", type: "MongoEmbedMacro")
#else /* os(Linux) */
  public typealias MongoID = MongoKitten.ObjectId
  public typealias MongoEnum = CaseIterable & Codable & Hashable
  public typealias MongoList<T> = [T]
  public typealias MongoRef<T> = MongoID
  public typealias MongoSet<T: Hashable> = Set<T>
  public typealias MongoMap<K: Hashable, V> = [K: V]
  public typealias UserRef = MongoID
  public typealias PropertyRef = MongoID
  public typealias BrandRef = MongoID
  public typealias PointLogRef = MongoID
  public typealias LinkingObjects<T> = [T]

  public protocol MongoModeled
  {}

  public protocol MongoEmbedded
  {}

  public typealias Modeled = Fluent.Model & Fluent.Fields & Content & Codable

  public typealias Embedded = Codable & Content

  public extension MongoID
  {
    init(string: String) throws
    {
      self = MongoID(string) ?? MongoID.generate()
    }

    static func generate() -> MongoID
    {
      self.init()
    }

    var stringValue: String
    {
      hexString
    }

    var hex: String
    {
      hexString
    }
  }

  @attached(member, names: arbitrary)
  @attached(memberAttribute)
  @attached(extension, conformances: Modeled, names: named(IDValue), named(DefaultTimestampFormat), named(schema), named(update))
  public macro MongoModel() = #externalMacro(module: "MongoMacros", type: "MongoModelMacro")

  @attached(member, names: arbitrary)
  @attached(memberAttribute)
  @attached(extension, conformances: Embedded)
  public macro MongoEmbed() = #externalMacro(module: "MongoMacros", type: "MongoEmbedMacro")
#endif /* os(Linux) */
