require "./spec_helper"

dataclass Person{name : String, age : Int = 18}
dataclass Address{line1 : String, postcode : String}
dataclass Profile{person : Person, address : Address}

class A
  def tick
    "called_tick"
  end
end

dataclass B{id : Int32} < A
dataclass C{id : Int32}
dataclass Compound{id : String, b : B, c : C}

dataclass WithTypeParam(T){field : T}

describe DataClass do
  p = Person.new("Brian", 16)
  address = Address.new("10 Strand", "EC1")
  profile = Profile.new(p, address)
  comp = Compound.new("an-id", B.new(42), C.new(2))

  it "defines a constructor" do
    p.class.should eq(Person)
  end

  it "supports inheritance" do
    B.new(id: 123).is_a?(A).should be_true
    C.new(id: 123).is_a?(A).should be_false

    B.new(id: 123).tick.should eq("called_tick")
  end

  it "supports type parameters" do
    with_str = WithTypeParam(String).new("value")
    typeof(with_str.field).should eq(String)

    with_int = WithTypeParam(Int32).new(2)
    typeof(with_int.field).should eq(Int32)
  end

  it "defines getters for each field" do
    p.name.should eq("Brian")
    p.age.should eq(16)
  end

  it "provides a copy constructor" do
    john = p.copy(name: "John")
    john.name.should eq("John")
    john.age.should eq(p.age)

    john.copy(age: 1).age.should eq(1)
  end

  it "provides a copy constructor that does not have side effects on the caller" do
    name, age = p.to_tuple
    john = p.copy(name: "John")
    p.should eq(Person.new(name, age))
  end

  it "supports default params" do
    p_with_default_age = Person.new("Brian")
    p_with_default_age.age.should eq(18)
  end

  it "supports destructuring assignment" do
    name, age = p
    name.should eq(p.name)
    age.should eq(p.age)

    name, _ = p
    name.should eq(p.name)
  end

  it "supports destructuring assignment on nested data classes" do
    _, b, c = comp
    b.should eq(comp.b)
    c.should eq(comp.c)

    id, _, c = comp
    id.should eq(comp.id)
    c.should eq(comp.c)
  end

  it "supports conversion to tuple" do
    p.to_tuple.should eq({p.name, p.age})
  end

  it "to_tuple on nested data classes does not get called recursively" do
    comp.to_tuple.should eq({comp.id, comp.b, comp.c})
  end

  it "supports conversion to named tuple" do
    p.to_named_tuple.should eq({"name": p.name, "age": p.age})
  end

  it "to_named_tuple on nested data classes does not get called recursively" do
    comp.to_named_tuple.should eq({"id": comp.id, "b": comp.b, "c": comp.c})
  end

  it "does not define setters" do
    p.responds_to?(:"name=").should eq(false)
    p.responds_to?(:"age=").should eq(false)
  end

  it "defines a human friendly to_s method" do
    p.to_s.should eq("Person(Brian, 16)")
    profile.to_s.should eq("Profile(Person(Brian, 16), Address(10 Strand, EC1))")
  end

  it "defines equality as structural comparison" do
    p.should eq(Person.new(p.name, p.age))
  end

  it "defines #hash based on the instance fields" do
    p1 = Person.new(p.name, p.age)
    p.hash.should eq(p1.hash)
  end

  it "supports comparison of nested structures" do
    b = Compound.new(comp.id, comp.b, comp.c)
    comp.should eq(b)

    different = Compound.new("other-id", B.new(42), C.new(2))
    comp.should_not eq(different)
  end

  it "supports pattern-based parameter extraction" do
    a, b = nil, nil
    Person[a, b] = p
    a.should eq(p.name)
    b.should eq(p.age)
  end

  it "supports nested pattern-based parameter extraction" do
    a, b, c, d = nil, nil, nil, nil
    Profile[Person[a, b], Address[c, d]] = profile
    a.should eq(profile.person.name)
    b.should eq(profile.person.age)
    c.should eq(profile.address.line1)
    d.should eq(profile.address.postcode)
  end

  it "supports underscore in pattern-based parameter extraction" do
    line1 = nil
    Profile[_, Address[line1, _]] = profile
    line1.should eq(profile.address.line1)
  end

  it "supports basic case matching" do
    case p
    when Person
      # do nothing
    else fail("should have matched the above")
    end

    case p
    when Person.new(p.name, p.age)
      # do nothing
    else fail("should have matched the above")
    end
  end
end
