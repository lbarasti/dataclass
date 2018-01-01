require "./case_class/*"

# TODO: Write documentation for `CaseClass`
macro case_class(name)
  class {{name.type}}
    {% for key in name %}
      getter {{key.var}}
    {% end %}

    def initialize({% for key in name %}
      @{{key}},
    {% end %})
    end

    def to_s(io)
      fields = [{% for key in name %}@{{key.var}},{% end %}]
      io << "#{self.class}(#{fields.join(", ")})"
    end
  end
end
