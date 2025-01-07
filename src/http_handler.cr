require "./honeybadger-integrations"
require "http"

class Honeybadger::Integrations::HTTPHandler
  include HTTP::Handler

  def initialize(@type = "http.server.request")
  end

  def call(context)
    error = nil
    start = Time.monotonic

    begin
      call_next context
    rescue ex
      error = ex
      raise ex
    ensure
      Honeybadger.event(
        type: @type,
        trace_id: Fiber.current.honeybadger_trace_id,
        "http.request.method": context.request.method,
        "http.request.resource": context.request.resource,
        "http.response.status": context.response.status_code,
        "http.response.status_message": context.response.status.to_s,
        duration_ms: (Time.monotonic - start).total_milliseconds,
        error: error,
      )
    end
  end
end
