require 'query_matchers/query_execution_matcher'

describe QueryMatchers::QueryExecutionMatcher do
  describe "#matches?" do
    let(:matcher) { described_class.new(4) }

    it "returns true if the number of queries performed matched the expectation" do
      matcher.matches?(proc { execute_queries(4) }).should == true
    end

    it "returns false if the number of queries performed doesn't match the expectation" do
      matcher.matches?(proc { execute_queries(3) }).should == false
    end

    it "only considers INSERT, SELECT, UPDATE, and DELETE operations" do
      target = proc do
        perform_sql "INSERT foo"
        perform_sql "SELECT foo"
        perform_sql "UPDATE foo"
        perform_sql "DELETE foo"
        perform_sql "DANCE foo"
      end

      matcher.matches?(target).should == true
    end

    def execute_queries(n)
      n.times do
        perform_sql("SELECT * FROM something")
      end
    end

    def perform_sql(sql)
      ActiveSupport::Notifications.instrument('sql.active_record', sql: sql)
    end
  end
end
