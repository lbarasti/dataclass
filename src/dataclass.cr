require "./dataclass/*"

macro dataclass(class_def)
  {% if class_def.is_a?(ArrayLiteral) %}
    {% literal = class_def %}
    {% base_class = nil %}
  {% elsif class_def.is_a?(Call) &&
             class_def.name == "<" %}
    {% literal = class_def.receiver %}
    {% base_class = class_def.args[0] %}
  {% end %}

  class {{literal.type}} {% if base_class %} < {{base_class}} {% end %}
    {% for key in literal %}
      getter {{key.var}}
    {% end %}

    def initialize({{*literal.map { |key| "@#{key}".id }}})
    end

    {{yield}}

    def_equals_and_hash({% for key in literal %}@{{key.var}},{% end %})

    def copy({% for key in literal %}{{key.var}} = @{{key.var}},{% end %}) : {{literal.type}}
      {{literal.type}}.new({% for key in literal %}{{key.var}},{% end %})
    end

    def [](idx)
      [
        {% for key, idx in literal %}
          @{{key.var}},
        {% end %}
      ][idx]
    end

    def to_tuple
      { \
        {% for key, idx in literal %}
          @{{key.var}} {% if idx < literal.size - 1 %}, {% end %} \
        {% end %}
      }
    end

    def to_named_tuple
      { \
        {% for key, idx in literal %}
          "{{key.var}}": @{{key.var}} {% if idx < literal.size - 1 %}, {% end %} \
        {% end %}
      }
    end

    def to_s(io)
      io << "#{self.class}("
      {% for key, idx in literal %}
        io << @{{key.var}}
        {% if idx < literal.size - 1 %}
          io << ", "
        {% end %}
      {% end %}
      io << ")"
    end

    macro []=({% for key, idx in literal %}{{key.var}}_pattern,{% end %} rhs)
      {% for key, idx in literal %}rhs_{{key.var}}{% if idx < literal.size - 1 %}, {% end %}{% end %} = \{{rhs}}.to_tuple

      {% for key, idx in literal %}
        \{{ {{key.var}}_pattern }} = rhs_{{key.var}}
      {% end %}
    end

    macro inherited
      \{% raise "Illegal inheritance: case classes cannot be inherited from.\n" +
        "Define an abstract class and have both '#{@type}' and '{{literal.type}}' inherit from that, instead." %}
    end
  end
end
