[![GitHub release](https://img.shields.io/github/release/lbarasti/dataclass.svg)](https://github.com/lbarasti/dataclass/releases)
[![Build Status](https://travis-ci.org/lbarasti/dataclass.svg?branch=master)](https://travis-ci.org/lbarasti/dataclass)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)


# dataclass

A [Crystal](http://crystal-lang.org/) macro to ease the definition of *data classes*, i.e. classes whose main purpose is to hold data.

Data class instances are immutable, and provide a natural implementation for the most common methods.
They also define some basic pattern matching functionality, to ease data extraction.

Follow the links to read more about data classes in [Kotlin](https://kotlinlang.org/docs/reference/data-classes.html), [Scala](https://docs.scala-lang.org/tour/case-classes.html) and [Python](https://docs.python.org/3/library/dataclasses.html).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  dataclass:
    github: lbarasti/dataclass
```

## Usage

```crystal
require "dataclass"
```

Let's define a class with read-only fields

```crystal
dataclass Person{name : String, age : Int = 18}
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

`to_s` is also defined to provide a human readable string representation for a data class instance

```crystal
puts p # prints "Person(Rick, 28)"
```

Instances of a data class are immutable. A `copy` method is provided to build new versions of a given object

```crystal
p.copy(age: p.age + 1) # => Person(Rick, 29)
```


### Pattern-based parameter extraction

Data classes enable you to extract parameters using some sort of pattern matching. This is powered by a custom definition of the `[]=` operator on the data class itself.

For example, given the data classes

```crystal
dataclass Person{name : String, age : Int = 18}
dataclass Address{line1 : String, postcode : String}
dataclass Profile{person : Person, address : Address}
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

Data classes support destructuring assignment. There is no magic involved here: data classes simply implement the indexing operator `#[](idx)`.

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

The macro also defines a `to_named_tuple` method, which provides a natural transformation of your data class instance to `NamedTuple`

```crystal
  person.to_named_tuple # => {"name": "Alice", "age": 43}
```
Mind that, by design, both `to_tuple` and `to_named_tuple` are not recursive - so they will not convert data class fields to tuples / named tuples respectively.

### Support for inheritance

The `dataclass` macro supports inheritance, so the following code is valid

```crystal
class Vehicle; end
dataclass Car{passengers : Int16} < Vehicle
```

### Support for type parameters

The `dataclass` macro supports type parameters, so the following code is valid

```crystal
dataclass Wrapper(T){value : T}
```

### Support for defining additional methods

The `dataclass` macro supports defining additional methods on your data class. If you pass the dataclass macro a code block, the body of the code block will be pasted into body of the expanded class definition.

```crystal
dataclass Person{name : String} do
  def hello
    "Hello #{@name}"
  end
end

Person.new("Matt").hello  # => "Hello Matt"
```

This also works in conjunction with inheritance.

### Under the hood

The `dataclass` macro expands such that following definitions are equivalent.

```crystal
dataclass Person{name : String, age : Int = 18} < OtherType do
  def hello
    "Hello #{@name}"
  end
end
```

```crystal
class Person < OtherType
  getter(name)
  getter(age)

  def initialize(@name : String, @age : Int = 18)
  end

  def hello
    "Hello #{@name}"
  end

  def_equals_and_hash(@name, @age)

  def copy(name = @name, age = @age) : Person
    Person.new(name, age)
  end

  def [](idx)
    [@name, @age][idx]
  end

  def to_tuple
    {@name, @age}
  end

  def to_named_tuple
    {name: @name, age: @age}
  end

  def to_s(io)
    fields = [@name, @age]
    io << "#{self.class}(#{fields.join(", ")})"
  end
end
```

### Known Limitations

* dataclass definition must have *at least* one argument. This is by design. Use `class NoArgClass; end` instead.
* trying to inherit from a data class will lead to a compilation error.
```crystal
dataclass A{id : String}
dataclass B{id : String, extra : Int32} < A # => won't compile
```
This is by design. Try defining your data classes so that they [inherit from a commmon abstract class](https://stackoverflow.com/a/12706475) instead.

## Development

To expand the macro

```
crystal tool expand -c <path/to/file.cr>:<line>:<col> <path/to/file.cr>
```

## Contributing

1. Fork it ( https://github.com/lbarasti/dataclass/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [lbarasti](https://github.com/lbarasti) - creator, maintainer
- [Matthew Berry](https://github.com/mattrberry) - contributor
