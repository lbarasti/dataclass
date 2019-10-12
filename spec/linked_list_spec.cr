require "./spec_helper"

abstract class List(T)
  def self.empty : LNil(T)
    LNil(T).new
  end
end

class LNil(T) < List(T)
end

LLNil = LNil(Nil).new

case_class LCons(T){head : T, tail : List(T)} < List(T)

def lenght(list : LCons(T)) : Int forall T
  1 + lenght(list.tail)
end

def lenght(list : LNil(T)) : Int forall T
  0
end

def contains(list : LCons(T), value : T) : Bool forall T
  list.head == value ? true : contains(list.tail, value)
end

def contains(list : LNil(T), value : T) : Bool forall T
  false
end

def find(list : LCons(T), predicate : T -> Bool) : T? forall T
  predicate.call(list.head) ? list.head : find(list.tail, predicate)
end

def find(list : LNil(T), predicate : T -> Bool) : T? forall T
  nil
end

def filter(list : LCons(T), predicate : T -> Bool) : List(T) forall T
  predicate.call(list.head) ? LCons.new(list.head, filter(list.tail, predicate)) : filter(list.tail, predicate)
end

def filter(list : LNil(T), predicate : T -> Bool) : List(T) forall T
  List(T).empty
end


describe CaseClass do
  
  it "supports recursive structures" do
    l : List(String) = LCons.new("hello", LCons.new("1", List(String).empty))
    puts lenght(l)
    puts contains(l, "1")
    puts find(l, ->(a : String){a == ""})
    puts filter(l, ->(a : String){a.size < 10})
  end

end
