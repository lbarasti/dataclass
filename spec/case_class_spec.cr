require "./spec_helper"

case_class Person{name : String, age : Int = 18}

class A
  def tick
    "called_tick"
  end
end

case_class B{id : Int32} < A
case_class C{id : Int32}

describe CaseClass do
  p = Person.new("Brian", 16)

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

  it "does not define setters" do
    p.responds_to?(:"name=").should eq(false)
    p.responds_to?(:"age=").should eq(false)
  end

  it "defines a human friendly to_s method" do
    p.to_s.should eq("Person(Brian, 16)")
  end
end
