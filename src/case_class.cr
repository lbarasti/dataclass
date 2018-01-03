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

    def ==(other : {{literal.type}})
      {% for key, idx in literal %}
        {{key.var}} == other.{{key.var}} {% if idx < literal.size - 1 %} && {% end %}
      {% end %}
    end

    def to_s(io)
      fields = [{% for key in literal %}@{{key.var}},{% end %}]
      io << "#{self.class}(#{fields.join(", ")})"
    end
  end
end
