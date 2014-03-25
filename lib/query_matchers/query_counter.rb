module QueryMatchers
  class QueryCounter
    OPERATIONS = %w(SELECT INSERT UPDATE DELETE)

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
      OPERATIONS.any? {|op| sql.start_with?(op) }
    end
  end
end
