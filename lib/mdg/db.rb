require 'fileutils'
require 'active_record'

module Mdg
  module DB
    def self.prepare
      database_path = File.join(ENV['HOME'], '.mdg', 'mdg.sqlite3')

      connect_database database_path
      create_deeds_table_if_not_exists database_path
      create_timestamps_table_if_not_exists database_path
    end

    def self.connect_database(path)
      spec = { adapter: 'sqlite3', database: path }
      ActiveRecord::Base.establish_connection spec
    end

    def self.create_deeds_table_if_not_exists(path)
      create_database_path path

      connection = ActiveRecord::Base.connection

      return if connection.table_exists?(:deeds)

      connection.create_table :deeds do |t|
        t.column :content, :text,   null: false
        t.column :hour,    :float,  null: false
        t.timestamps
      end

      connection.add_index :deeds, :created_at
    end

    def self.create_timestamps_table_if_not_exists(path)
      create_database_path path

      connection = ActiveRecord::Base.connection

      return if connection.table_exists?(:timestamps)

      connection.create_table :timestamps do |t|
        t.references :deed,              foreign_key: true
        t.column     :totaltime, :float, null: false
        t.timestamps
      end

      connection.add_index :timestamps, [:deed_id, :created_at]
    end

    def self.create_database_path(path)
      FileUtils.mkdir_p File.dirname(path)
    end

    private_class_method :connect_database, :create_deeds_table_if_not_exists, :create_timestamps_table_if_not_exists, :create_database_path
  end
end
