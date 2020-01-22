class CreateTableAndViewForTesting < ActiveRecord::Migration[6.0]
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
