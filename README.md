
# README

I am in the process of updating an app from 5.2 to 6.0 that uses postgresql@10.11.  The app relies on a number of postgres views and functions.  These views and functions are created in migrations.

_In the 5.2 series, postgres views and functions (and data seeded during a migration) persist between test runs._  **However, in 6.0 the views and functions are being wiped between tests (which breaks almost our entire test suite because the models in the app rely on them).**

I created two repos that demonstrate the different behavior between versions.  I would appreciate any insight or advice on the expectations of this behavior going forward and whether this is indeed a 'bug' or if it will be the new way of doing testing business and suggestions for moving forward.

### Two repositories that demonstrate the difference between 5.2 and 6.0

* [Rails 5 - passing](https://github.com/thornomad/issue-38279-rails-5)
* [Rails 6 - failing](https://github.com/thornomad/issue-38279-rails-6)

_I tried a Docker approach (first time) in case there is something unique about my setup.  You should be able to test this without docker, however._

```fish
# Download the repo, install, migrate, run tests
git clone git@github.com:thornomad/issue-38279-rails-6.git
cd issue-38279-rails-6
bundle install
yarn install --check-files
bundle exec rake db:create RAILS_ENV=test
bundle exec rake db:migration RAILS_ENV=test
bundle exec rake

# DOCKER approach
git clone git@github.com:thornomad/issue-38279-rails-6.git
cd issue-38279-rails-6
docker-compose build
docker-compose run --rm app bundle install
docker-compose run --rm app rails db:create RAILS_ENV=test
docker-compose run --rm app rails db:migrate RAILS_ENV=test
docker-compose run --rm app rake

# tests should pass
```

### Example migration that creates a view and seeds data

```ruby
# db/migrate/xxxx_create_table_and_view_for_testing.rb
class CreateTableAndViewForTesting < ActiveRecord::Migration[5.2] # or [6.0] !
  class Person < ApplicationRecord; end

  def up
    create_table :people do |t|
      t.string :name
    end

    # Simple view that should persist
    connection.execute <<-SQL
      DROP VIEW IF EXISTS view_people;
      CREATE OR REPLACE VIEW view_people AS
        SELECT id, name
        FROM people
    SQL

    # Seed the database with some values
    (1..5).each { |i| Person.create!(name: "Person ##{i}") }
  end

  def down
    connection.execute <<-SQL
      DROP VIEW IF EXISTS view_people;
    SQL
    drop_table :people
  end
end
```

### Test that expects to find the view and seeded data from migration

```ruby
# test/models/person_test.rb
require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  class Person < ApplicationRecord; end

  class ViewPerson < ApplicationRecord
    self.table_name = 'view_people'
  end

  test 'there are five seeded people' do
    assert_equal 5, Person.count
  end

  test 'there are five people in the view' do
    assert_equal 5, ViewPerson.count
  end

end
```

### Expected behavior
I would expect the tests to pass in 6.0, as they do in the 5.2 app.

### Actual behavior
In the 6.0 app the tests fail.  It appears the test suite is wiping any custom postgres view or function as well as clearing any seeded data from a migration.  This does not happen in 5.2.

### Appreciate your help

Thank you!

### System configuration
**Rails version**: 6.0.2.1 (I pinned it at a specific forward reference in the 6-0-stable branch to eliminate an unrellated exception, so the test repo is actually slightly ahead of this version)

**Ruby version**: 2.6.3
See the single migration file and the single test, committed seperately.  These
tests are failing in 6.0 but passing in 5.2 under the same conditions.

