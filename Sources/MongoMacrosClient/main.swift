/* -----------------------------------------------------------
 * :: :  G  H  O  S  T  :                                   ::
 * -----------------------------------------------------------
 *
 * CREDITS.
 *
 * T.Furby              @furby-tm       <devs@wabi.foundation>
 * D.Kirkpatrick  @dkirkpatrick99  <d.kirkpatrick99@gmail.com>
 *
 *                                         Copyright (C) 2023.
 *                                        All Rights Reserved.
 * -----------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ----------------------------------------------------------- */

import Mongo

@MongoModel
public final class Person
{
  public var name: String

  public var age: Int
}

let person = Person(name: "Tyler", age: 27)

print("The value of person produced: \(person)")
