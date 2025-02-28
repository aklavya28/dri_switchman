namespace :db do
  desc "Add missing columns to tables based on schema"
  task add_missing_columns: :environment do
    ActiveRecord::Base.establish_connection
    # schema = Rails.application.eager_load! && ActiveRecord::Base.connection.schema_cache
    schema = ActiveRecord::Base.connection
    # puts schema.tables.include?("orders")
    # Iterate over all tables in the database
    schema.tables.each do |table|

      next if table == "schema_migrations" # Skip schema_migrations table
      # if table == "orders"
      #   puts existing_columns = schema.columns(table).map(&:name)
      #   puts "---------------------"
      #   puts defined_columns = ActiveRecord::Base.connection.columns(table).map(&:name)
      #   puts "---------------------"
      #   puts missing_columns = defined_columns - existing_columns
      # end
      # Get table columns from the database
      existing_columns = schema.columns(table).map(&:name)

      # Get columns defined in db/schema.rb
      defined_columns = ActiveRecord::Base.connection.columns(table).map(&:name)

      # Find missing columns
      missing_columns = defined_columns - existing_columns

      # Add missing columns to the table
      missing_columns.each do |column|
        column_definition = defined_columns.find { |col| col.name == column }
        column_type = column_definition.sql_type
        options = {
          null: column_definition.null,
          default: column_definition.default
        }

        # Add the missing column
        ActiveRecord::Base.connection.add_column(table, column, column_type.to_sym, **options)
        puts "Added column '#{column}' to table '#{table}'"
      end
    end

    puts "All missing columns have been added!"
  end
end
