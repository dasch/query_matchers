require 'active_support/notifications'
require 'query_matchers/query_counter'

describe QueryMatchers::QueryCounter do
  let(:counter) { described_class.new }

  it "records all relevant SQL operations performed in the target block" do
    query = "SELECT * FROM somewhere"
    counter.execute!(sql_target(query))

    counter.queries.should == [query]
  end

  it "counts the number of queries performed in the target block" do
    target = proc { 3.times { perform_sql("INSERT INTO jokes") } }
    counter.execute!(target)

    counter.query_count.should == 3
  end

  it "counts INSERT queries" do
    counter.execute!(sql_target("INSERT INTO jokes"))

    counter.query_count.should == 1
  end

  it "counts UPDATE queries" do
    counter.execute!(sql_target("UPDATE mood SET laughing = 0"))

    counter.query_count.should == 1
  end

  it "counts DELETE queries" do
    counter.execute!(sql_target("DELETE FROM goodwill"))

    counter.query_count.should == 1
  end

  it "counts SELECT queries" do
    counter.execute!(sql_target("SELECT FROM inventory"))

    counter.query_count.should == 1
  end

  it "doesn't count any other type of query" do
    counter.execute!(sql_target("BREAKDANCE"))

    counter.query_count.should == 0
  end

  def sql_target(sql)
    proc { perform_sql(sql) }
  end

  def perform_sql(sql)
    ActiveSupport::Notifications.instrument('sql.active_record', sql: sql)
  end
end
