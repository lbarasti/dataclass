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

case_class Eq{a : Expr(Int32), b : Expr(Int32)} < Expr(Bool)

expr = Eq.new(Add.new(IntExpr.new(2), IntExpr.new(3)), IntExpr.new(5))

match case expr
when Eq[Add[a, b], IntExpr[_]]
  puts(a, b)
end

def eval(expr : Expr(Int32) | Nil) : Int32
  if expr.nil?
    42
  else
    match case expr
    when Add[a, b]
      eval(a) + eval(b)
    when IntExpr[a]
      a.as(Int32)
    else 42
    end
  end
end

result = match case expr
when Eq[a, b]
  eval(a)
end

puts result