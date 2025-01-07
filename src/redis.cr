require "./honeybadger-integrations"
require "redis"

class Redis::Connection
  def run(command, retries = 5)
    error = nil
    start = Time.monotonic

    begin
      previous_def(command, retries)
    rescue ex
      error = ex
      raise ex
    ensure
      Honeybadger.event(
        type: "redis.connection.run",
        trace_id: Fiber.current.honeybadger_trace_id,
        command: command,
        duration_ms: (Time.monotonic - start).total_milliseconds,
        error: error,
      )
    end
  end
end
