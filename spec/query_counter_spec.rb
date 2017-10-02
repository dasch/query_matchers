require 'active_support/notifications'
require 'query_matchers/query_counter'

describe QueryMatchers::QueryCounter do
  let(:counter) { described_class.new }

  it "records all relevant SQL operations performed in the target block" do
    query = "SELECT * FROM somewhere"
    counter.execute!(sql_target(query))

    expect(counter.queries).to eq([query])
  end

  it "counts the number of queries performed in the target block" do
    target = proc { 3.times { perform_sql("INSERT INTO jokes") } }
    counter.execute!(target)

    expect(counter.query_count).to eq(3)
  end

  it "counts INSERT queries" do
    counter.execute!(sql_target("INSERT INTO jokes"))

    expect(counter.query_count).to eq(1)
  end

  it "counts UPDATE queries" do
    counter.execute!(sql_target("UPDATE mood SET laughing = 0"))

    expect(counter.query_count).to eq(1)
  end

  it "counts DELETE queries" do
    counter.execute!(sql_target("DELETE FROM goodwill"))

    expect(counter.query_count).to eq(1)
  end

  it "counts SELECT queries" do
    counter.execute!(sql_target("SELECT FROM inventory"))

    expect(counter.query_count).to eq(1)
  end

  it "counts queries with a bit of whitespace" do
    counter.execute!(sql_target("  SELECT FROM inventory"))

    expect(counter.query_count).to eq(1)
  end

  it "doesn't count any other type of query" do
    counter.execute!(sql_target("BREAKDANCE"))

    expect(counter.query_count).to eq(0)
  end

  it "ignores Rails 5's schema queries" do
    counter.execute!(sql_target(<<-SQL))
      SELECT column_name
        FROM information_schema.key_column_usage
       WHERE constraint_name = 'PRIMARY'
         AND table_schema = DATABASE()
         AND table_name = 'jokes'
       ORDER BY ordinal_position
    SQL

    expect(counter.query_count).to eq(0)
  end

  def sql_target(sql)
    proc { perform_sql(sql) }
  end

  def perform_sql(sql)
    ActiveSupport::Notifications.instrument('sql.active_record', sql: sql)
  end
end
