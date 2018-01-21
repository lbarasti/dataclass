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

```
age, postcode = nil, nil
Profile[Person[_, age], Address[_, postcode]] = profile

age == profile.person.age # => true
postcode == profile.address.postcode # => true
```

Note that it is necessary for the variables used in the pattern matching to be initialized *before* they appear in the pattern.

Skipping the initialization step will produce a compilation error as soon as you try to reuse such variables.

### Case classes and ADTs

If you're into ADTs, then you will enjoy `case_class` support for inheritance. Here is a sample implementation for a calculator data types.

```crystal
abstract class Expr(T)
end

case_class IntExpr{value : Int32} < Expr(Int32)

case_class BoolExpr{value : Bool} < Expr(Bool)

case_class Add{a : Expr(Int32), b : Expr(Int32)} < Expr(Int32)

case_class Eq{a : Expr(Int32), b : Expr(Int32)} < Expr(Bool)
```

### Known Limitations
* case_class definition must have *at least* one argument. This is by design. Use `class NoArgClass; end` instead.
* case_class definitions are body-free. If you want to define additonal methods on a case class, then just re-open the definition:

```
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
