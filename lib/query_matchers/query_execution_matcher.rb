require 'active_support/notifications'

module QueryMatchers
  class QueryExecutionMatcher
    OPERATIONS = %w(SELECT INSERT UPDATE DELETE)

    def initialize(expected)
      @expected = expected
    end

    def matches?(target)
      @target = target
      @events = []

      subscriber = lambda do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        sql = event.payload[:sql]

        if OPERATIONS.any? {|op| sql.start_with?(op) }
          @events << event
        end
      end

      ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record', &@target)

      num_queries == @expected
    end

    def failure_message
      "expected block to execute #{@expected} SQL queries, " <<
        "but executed #{num_queries}: \n\n" <<
        query_list.map {|q| " - #{q}" }.join("\n")
    end

    def negative_failure_message
      "expected block not to execute #{@expected} SQL queries, but did"
    end

    private

    def num_queries
      @events.size
    end

    def query_list
      @events.map {|event| event.payload[:sql] }
    end
  end
end
