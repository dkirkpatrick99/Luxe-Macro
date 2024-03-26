
import Mongo

@MongoModel
public final class Person
{
  public var name: String

  public var age: Int
}

let person = Person(name: "Tyler", age: 27)

print("The value of person produced: \(person)")
