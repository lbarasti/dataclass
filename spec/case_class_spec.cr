require "./spec_helper"

case_class Person{name : String, age : Int = 18}

class A
  def tick
    "called_tick"
  end
end

case_class B{id : Int32} < A
case_class C{id : Int32}
case_class Compound{id : String, b : B, c : C}

describe CaseClass do
  p = Person.new("Brian", 16)
  comp = Compound.new("an-id", B.new(42), C.new(2))
  it "defines a constructor" do
    p.class.should eq(Person)
  end

  it "supports inheritance" do
    B.new(id: 123).is_a?(A).should be_true
    C.new(id: 123).is_a?(A).should be_false

    B.new(id: 123).tick.should eq("called_tick")
  end

  it "defines getters for each field" do
    p.name.should eq("Brian")
    p.age.should eq(16)
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

  it "supports destructuring assignment on nested case classes" do
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

  it "recursively calls to_tuple on nested case classes" do
    comp.to_tuple.should eq({comp.id, {comp.b.id}, {comp.c.id}})
  end

  it "does not define setters" do
    p.responds_to?(:"name=").should eq(false)
    p.responds_to?(:"age=").should eq(false)
  end

  it "defines a human friendly to_s method" do
    p.to_s.should eq("Person(Brian, 16)")
  end

  it "defines equality as structural comparison" do
    p.should eq(Person.new(p.name, p.age))
  end

  it "supports comparison of nested structures" do
    b = Compound.new(comp.id, comp.b, comp.c)
    comp.should eq(b)

    different = Compound.new("other-id", B.new(42), C.new(2))
    comp.should_not eq(different)
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
