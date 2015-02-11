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
        @counter.queries.map {|q| " - #{q}" }.join("\n") << "\n\n" <<
        "Total queries: #{@counter.query_count}"
    end

    def failure_message_when_negated
      "expected block not to execute #{@expected} SQL queries, but did"
    end

    # RSpec 2 compatibility:
    alias_method :failure_message_for_should, :failure_message
    alias_method :failure_message_for_should_not, :failure_message_when_negated

    def supports_block_expectations?
      true
    end
  end
end
