[![GitHub release](https://img.shields.io/github/release/lbarasti/case_class.svg)](https://github.com/lbarasti/case_class/releases)
[![Build Status](https://travis-ci.org/lbarasti/case_class.svg?branch=master)](https://travis-ci.org/lbarasti/case_class)


# case_class

The `case_class` macro defines a class whose instances are immutable and provide a natural implementation for the most common methods. It also defines some basic pattern matching functionality, to ease data extraction.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  case_class:
    github: lbarasti/case_class
```

## Usage

```crystal
require "case_class"
```

Let's define a class with read-only fields

```crystal
case_class Person{name : String, age : Int = 18}
```

We can now create instances and access fields

```crystal
p = Person.new("Rick", 28)

p.name # => "Rick"
p.age # => 28
```

The equality operator is defined to perform structural comparison

```crystal
q = Person.new("Rick", 28)

p == q # => true
```

The `hash` method is defined accordingly. This guarantees predictable behaviour with Set and Hash.

```crystal
  visitors = Set(Person).new
  visitors << p
  visitors << q

  visitors.size # => 1
 ```

`to_s` is also defined to provide a human readable string representation for a case class instance

```crystal
puts p # prints "Person(Rick, 28)"
```

Instances of a case class are immutable. A `copy` method is provided to build new versions of a given object

```crystal
p.copy(age: p.age + 1) # => Person(Rick, 29)
```


### Pattern-based parameter extraction
Case classes enable you to extract parameters using some sort of pattern matching. This is powered by a custom definition of the `[]=` operator on the case class itself.

For example, given the case classes

```crystal
case_class Person{name : String, age : Int = 18}
case_class Address{line1 : String, postcode : String}
case_class Profile{person : Person, address : Address}
```

and a `Profile` instance `profile`

```crystal
profile = Profile.new(Person.new("Alice", 43), Address.new("10 Strand", "EC1"))
```

the following is supported

```crystal
age, postcode = nil, nil
Profile[Person[_, age], Address[_, postcode]] = profile

age == profile.person.age # => true
postcode == profile.address.postcode # => true
```

Note that it is necessary for the variables used in the pattern matching to be initialized *before* they appear in the pattern.

Skipping the initialization step will produce a compilation error as soon as you try to reuse such variables.


### Destructuring assignment
Case classes support destructuring assignment. There is no magic involved here: case classes simply implement the indexing operator `#[](idx)`.

```crystal
person, address = profile

person == profile.person # => true
address == profile.address # => true
```

The inconvenience with this approach is that the type of both `person` and `address` at compile time is going to be `String | Int32`. This might make your code a bit uglier than it needs to be.

To circumvent this limitation, the `to_tuple` method is also provided. This assigns the right type to each extracted parameter even at compile-time

```crystal
profile.to_tuple # => {Person(...), Address(...)}

person, address = profile.to_tuple

person == profile.person # => true
address == profile.address # => true
```

The macro also defines a `to_named_tuple` method, which provides a natural transformation of your case class instance to `NamedTuple`

```crystal
  person.to_named_tuple # => {"name": "Alice", "age": 43}
```
Mind that, by design, both `to_tuple` and `to_named_tuple` are not recursive - so they will not convert case class fields to tuples / named tuples respectively.

### Support for inheritance

The `case_class` macro supports inheritance, so the following code is valid

```crystal
class Vehicle
case_class Car{passengers : Int16} < Vehicle
```


### Known Limitations
* case_class definition must have *at least* one argument. This is by design. Use `class NoArgClass; end` instead.
* trying to inherit from a case class will lead to a compilation error.
```crystal
case_class A{id : String}
case_class B{id : String, extra : Int32} < A # => won't compile
```
This is by design. Try defining your case classes so that they [inherit from a commmon abstract class](https://stackoverflow.com/a/12706475) instead.
* case_class definitions are body-free. If you want to define additonal methods on a case class, then just re-open the definition:

```crystal
case_class YourClass{id : String}

class YourClass
  # additional methods here
end
```

## Development

To expand the macro

```
crystal tool expand -c <path/to/file.cr>:<line>:<col> <path/to/file.cr>
```

## Contributing

1. Fork it ( https://github.com/lbarasti/case_class/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [lbarasti](https://github.com/lbarasti) - creator, maintainer
