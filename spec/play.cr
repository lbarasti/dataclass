require "./spec_helper"

case_class Address{line1 : String, postcode : String}
case_class Person{name : String, address : Address}

address = Address.new("crouch hill", "N4 4AP")
p = Person.new("Lorenzo", address)

macro postpone(expr)
  {{expr}}
end

macro match(cs)
  {% for pattern, idx in cs.whens %}
    if {{pattern.conds[0]}} = {{cs.cond}}
      postpone {{pattern.body}}
    end
  {% end %}
end

match case p
  when Person[_, Address[a, postcode]]
    puts a
    puts "hello"
  when Person[_, Address[_, postcode]]
    puts 3
end

