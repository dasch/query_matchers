# QueryMatchers

Match the number of queries performed in any block of code. Allows setting in place regression tests for database performance.

## Installation

Add this line to your application's Gemfile:

    gem 'query_matchers'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install query_matchers

## Usage

```ruby
require 'query_matchers'

describe "something" do
  include QueryMatchers
  
  it "works!" do
    expect { magician.magic! }.to execute_queries(43)
    expect { does_not_hit_the_database }.to execute_no_queries
    expect { hits_the_database_once }.to execute_one_query
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
