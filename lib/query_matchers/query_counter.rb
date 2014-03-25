module QueryMatchers
  class QueryCounter
    OPERATIONS = %w(SELECT INSERT UPDATE DELETE)

    def initialize
      @events = []
    end

    def execute!(target)
      subscriber = lambda do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        sql = event.payload[:sql]

        if OPERATIONS.any? {|op| sql.start_with?(op) }
          @events << event
        end
      end

      ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record', &target)
    end

    def query_count
      @events.size
    end

    def queries
      @events.map {|event| event.payload[:sql] }
    end
  end
end
