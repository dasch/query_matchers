require 'active_support/core_ext/string/strip'
require 'query_matchers/query_execution_matcher'

describe QueryMatchers::QueryExecutionMatcher do
  let(:counter) { double("counter", query_count: 0) }
  let(:matcher) { described_class.new(4, counter) }

  describe "#matches?" do
    before do
      counter.stub(:execute!)
    end

    it "executes the target" do
      matcher.matches?(:whatever)
      counter.should have_received(:execute!).with(:whatever)
    end

    it "returns true if the number of queries performed matched the expectation" do
      counter.stub(:query_count) { 4 }
      matcher.matches?(:whatever).should == true
    end

    it "returns false if the number of queries performed doesn't match the expectation" do
      counter.stub(:query_count) { 3 }
      matcher.matches?(:whatever).should == false
    end
  end

  describe "#failure_message" do
    it "lists the queries performed in the target" do
      query1 = "SELECT FROM jokes WHERE puns > 3"
      query2 = "DELETE FROM jokes WHERE inappropriate = 1"

      counter.stub(:query_count) { 99 }
      counter.stub(:queries) { [query1, query2] }

      matcher.failure_message.should == <<-MESSAGE.strip_heredoc.chomp
        expected block to execute 4 SQL queries, but executed 99: 

         - SELECT FROM jokes WHERE puns > 3
         - DELETE FROM jokes WHERE inappropriate = 1
       MESSAGE
    end
  end
end
