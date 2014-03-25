require 'query_matchers/version'
require 'query_matchers/query_execution_matcher'

module QueryMatchers
  def execute_queries(n)
    QueryExecutionMatcher.new(n)
  end

  def execute_one_query
    QueryExecutionMatcher.new(1)
  end

  def execute_no_queries
    QueryExecutionMatcher.new(0)
  end
end
