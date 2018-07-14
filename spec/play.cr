require "./spec_helper"

case_class Address{line1 : String, postcode : String}
case_class Person{name : String, address : Address}

address = Address.new("crouch hill", "N4 4AP")
pe = Person.new("Lorenzo", address)

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

match case pe
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
when Eq[Add[a, IntExpr[3]], IntExpr[_]]
  puts("*", typeof(a), a.class)
end


Eq[Add[vv, IntExpr[3]], IntExpr[_]] = expr
postpone puts("**", typeof(vv), vv.class)

if Eq[Add[a, `IntExpr.new(3)`], IntExpr[_]] = expr
  postpone puts(typeof(a), a.class)
end

def eval(expr : IntExpr)
  expr.value
end

def eval(expr : Add)
  eval(expr.a) + eval(expr.b)
end

def eval(expr : Eq)
  eval(expr.a) == eval(expr.b)
end

p eval(expr)

match case expr
when Eq[a, b]
  eval(a.as(Expr(Int32)))
end
