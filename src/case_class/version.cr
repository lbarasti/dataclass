module CaseClass
  VERSION = File.read_lines(
    File.join(
      File.dirname(__FILE__), "..", "..", "shard.yml"))
      .find(&.match(/^version: (.*)/)) && $1
end
