require "./spec_helper"

abstract class Expr
end

case_class IntExpr{value : Int32} < Expr

case_class Add{a : Expr, b : Expr} < Expr

case_class Mult{a : Expr, b : Expr} < Expr

def eval(expr : Add)
  eval(expr.a) + eval(expr.b)
end

def eval(expr : IntExpr)
  expr.value
end

def eval(expr : Mult)
  eval(expr.a) * eval(expr.b)
end

describe CaseClass do
  
  it "supports nested structures" do
    p eval(Add.new(IntExpr.new(2), Mult.new(IntExpr.new(3), IntExpr.new(3))))
  end

end
