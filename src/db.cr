require "./honeybadger-integrations"
require "db"

class DB::Statement
  def_around_query_or_exec do |args|
    error = nil
    start = Time.monotonic

    begin
      yield
    rescue ex
      error = ex
      raise ex
    ensure
      Honeybadger.event(
        type: "db.statement",
        sql: command,
        args: args.map(&.to_s.inspect_unquoted),
        duration_ms: (Time.monotonic - start).total_milliseconds,
        error: error,
      )
    end
  end
end

class DB::ResultSet
  def each
    row_count = 0
    start = Time.monotonic

    begin
      result = previous_def do
        row_count += 1
        yield
      end
    rescue ex
      error = ex
    ensure
      Honeybadger.event(
        type: "db.result_set.each",
        row_count: row_count,
        column_count: column_count,
        column_names: column_names,
        duration_ms: (Time.monotonic - start).total_milliseconds,
        error: error,
      )

      result
    end
  end
end
