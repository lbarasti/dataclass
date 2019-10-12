require "./case_class/*"

# TODO: Write documentation for `CaseClass`
macro case_class(class_def)
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

    def initialize({% for key in literal %}
      @{{key}},
    {% end %})
    end

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

    def self.to_tuple(obj) # : Nil | { {% for key, idx in literal %}{{key.type}} {% if idx < literal.size - 1 %}, {% end %}{% end %} }
      if(obj.is_a?({{literal.type}}))
        obj.to_tuple
      else nil; end
    end

    def to_s(io)
      fields = [{% for key in literal %}@{{key.var}},{% end %}]
      io << "#{self.class}(#{fields.join(", ")})"
    end

    macro []=({% for key, idx in literal %}{{key.var}}_pattern,{% end %} rhs)
      begin
        {{literal.type}}.to_tuple(\{{rhs}}) && begin

          {% if literal.size == 1 %}
            %rhs_{0} = \{{rhs}}.as({{literal.type}}).to_tuple[0]
          {% else %}
            {% for key, idx in literal %}%rhs_{idx}{% if idx < literal.size - 1 %}, {% end %}{% end %} = \{{rhs}}.as({{literal.type}}).to_tuple
          {% end %}

          %is_match = true

          {% for key, idx in literal %}
            \{% if {{key.var}}_pattern.class_name == "Underscore" %}
            \{% elsif {{key.var}}_pattern.class_name == "Var" %}
              \{{ {{key.var}}_pattern }} = %rhs_{idx}
            \{% elsif {{key.var}}_pattern.class_name == "Call" %}
              \{% if {{key.var}}_pattern.name == "`" %}
                %is_match = %is_match && \{{ {{key.var}}_pattern.args[0].id }} === %rhs_{idx}
              \{% elsif {{key.var}}_pattern.args.size == 0 %}
                \{{ {{key.var}}_pattern }} = %rhs_{idx}
              \{% else %}
                %is_match = %is_match && (\{{ {{key.var}}_pattern }} = %rhs_{idx})
              \{% end %}
            \{% else %}
              %is_match = %is_match && \{{ {{key.var}}_pattern }} === %rhs_{idx}
            \{% end %}
          {% end %}

          \{{rhs}}.as({{literal.type}}).to_tuple
        end
      end
    end

    macro inherited
      \{% raise "Illegal inheritance: case classes cannot be inherited from.\n" +
        "Define an abstract class and have both '#{@type}' and '#{{{literal.type}}}' inherit from that, instead." %}
    end
  end
end
