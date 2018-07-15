require "./spec_helper"

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

expr1 = Eq.new(Mul.new(IntExpr.new(2), IntExpr.new(3)), IntExpr.new(5))
p eval(expr1)

expr2 = Eq.new(BoolExpr.new(false), BoolExpr.new(true))
p eval(expr2)

expr3 = Eq.new(IntExpr.new(3), IntExpr.new(3))
p eval(expr3)