module QueryMatchers
  class QueryCounter
    OPERATIONS = %w(SELECT INSERT UPDATE DELETE)
    RAILS5_INFORMATION_SCHEMA_REGEX = /^\s*SELECT.+FROM information_schema\./m

    def initialize
      @events = []
    end

    def execute!(target)
      ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record', &target)
    end

    def query_count
      @events.size
    end

    def queries
      @events.map {|event| event.payload[:sql] }
    end

    private

    def subscriber
      lambda do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        @events << event if count_query?(event.payload[:sql])
      end
    end

    def count_query?(sql)
      OPERATIONS.any? {|op| sql.lstrip.start_with?(op) } && !ignore_query?(sql)
    end

    def ignore_query?(sql)
      sql.match?(RAILS5_INFORMATION_SCHEMA_REGEX)
    end
  end
end
