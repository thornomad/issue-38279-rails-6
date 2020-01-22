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
