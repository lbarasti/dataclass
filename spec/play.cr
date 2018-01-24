require "./spec_helper"

case_class Address{line1 : String, postcode : String}
case_class Person{name : String, address : Address}

address = Address.new("crouch hill", "N4 4AP")
p = Person.new("Lorenzo", address)

macro postpone(expr)
  begin
    {{expr}}
  end
end

macro match(cs)
  {% for pattern, idx in cs.whens %}
    {% if idx == 0 %} if {% elsif idx < cs.whens.size %} elsif {% end %} {{pattern.conds[0]}} = {{cs.cond}}
      postpone ({{pattern.body}})
    {% if idx == cs.whens.size - 1 %} end {% end %}
  {% end %}
end

a = address.line1

match case p
  when Person[_, Address[`a`, postcode]]
    p [[a,postcode]]
  when Person[String, Address[_, postcode]]
    puts 3
end

abstract class Expr(T)
end

case_class IntExpr{value : Int32} < Expr(Int32)

case_class BoolExpr{value : Bool} < Expr(Bool)

case_class Add{a : Expr(Int32), b : Expr(Int32)} < Expr(Int32)

case_class Eq{a : Expr(Int32), b : Expr(Int32)} < Expr(Bool)

expr = Eq.new(Add.new(IntExpr.new(2), IntExpr.new(3)), IntExpr.new(5))

gg,hh = {expr.a, expr.b}
ff,jj = gg.a, gg.b
puts ff,jj, gg.to_tuple.class

# match case expr
#   when Eq[Add[a,b], c]
#     puts a
# end