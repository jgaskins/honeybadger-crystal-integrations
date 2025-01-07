require "honeybadger"

module Honeybadger::Integrations
  VERSION = "0.1.0"
end

class Fiber
  property honeybadger_trace_id : String do
    Random::Secure.hex(16)
  end

  property honeybadger_span_id : String do
    Random::Secure.hex(8)
  end
end
