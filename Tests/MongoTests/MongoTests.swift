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

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MongoMacros)
  import MongoMacros

  let testMacros: [String: Macro.Type] = [
    "MongoModel": MongoModelMacro.self,
  ]
#endif

final class MongoTests: XCTestCase
{
  func testMacro() throws
  {
    #if canImport(MongoMacros)
      assertMacroExpansion(
        """
        @MongoField
        final class Person
        {
          var name: String
          var age: Int
        }
        """,
        expandedSource:
        """
        final class Person: MongoModelable
        {
          @MongoField
          var name: String

          @MongoField
          var age: Int
        }
        """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
