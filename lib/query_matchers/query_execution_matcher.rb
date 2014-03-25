require 'active_support/notifications'
require 'query_matchers/query_counter'

module QueryMatchers
  class QueryExecutionMatcher
    def initialize(expected, counter = QueryCounter.new)
      @expected = expected
      @counter = counter
    end

    def matches?(target)
      @counter.execute!(target)

      @counter.query_count == @expected
    end

    def failure_message
      "expected block to execute #{@expected} SQL queries, " <<
        "but executed #{@counter.query_count}: \n\n" <<
        @counter.queries.map {|q| " - #{q}" }.join("\n")
    end

    def negative_failure_message
      "expected block not to execute #{@expected} SQL queries, but did"
    end
  end
end
