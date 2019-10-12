require "./spec_helper"

case_class Address{line1 : String, postcode : String}
case_class Person{name : String, address : Address}

address = Address.new("Some road", "N1 182")
p = Person.new("Lorenzo", address)

macro postpone(expr)

    {{expr}}

end

macro match(cs)
  {% for pattern, idx in cs.whens %}
    {% if idx == 0 %} if {% elsif idx < cs.whens.size %} elsif {% end %} {{pattern.conds[0]}} = {{cs.cond}}
      postpone (postpone ({{pattern.body}}))
    {% if idx == cs.whens.size - 1 %}
      {% if cs.else %} else {{cs.else}} {% end %}
      end
    {% end %}
  {% end %}
end

line = address.line1

match case p
when Person[_, Address[`line`, postcode]]
  p [[line, postcode]]
when Person[String, Address[_, postcode]]
  puts 3
end

abstract class Expr(T)
end

case_class IntExpr{value : Int32} < Expr(Int32)

case_class BoolExpr{value : Bool} < Expr(Bool)

case_class Add{a : Expr(Int32), b : Expr(Int32)} < Expr(Int32)

case_class Mul{a : Expr(Int32), b : Expr(Int32)} < Expr(Int32)

case_class Eq(T){a : Expr(T), b : Expr(T)} < Expr(Bool)

def eval(expr : Expr(Bool) | Expr(Int32))
  case expr
  when BoolExpr, IntExpr
    expr.value
  when Add
    eval(expr.a).as(Int32) + eval(expr.b).as(Int32)
  when Eq
    eval(expr.a) == eval(expr.b)
  else raise Exception.new
  end
end

expr1 = Eq.new(Add.new(IntExpr.new(2), IntExpr.new(3)), IntExpr.new(5))
p eval(expr1)

expr2 = Eq.new(BoolExpr.new(false), BoolExpr.new(true))
p eval(expr2)

expr3 = Eq.new(IntExpr.new(3), IntExpr.new(3))
p eval(expr3)