require 'pg'

module Rqd2
  class PgConnection

    attr_accessor :db

    def initialize(connection = nil)

      if connection.is_a?(PG::Connection)
        @db = connection
        return
      end

      @db = PG::Connection.new(
        :host => '127.0.0.1',
        :dbname => 'rqd2',
        :user => 'postgres',
        :password => ''
      )
    end

    def setup_schema
      @sqls = File.join(File.dirname(__FILE__), '..', '..', 'sql')
      Dir["#{@sqls}/*.sql"].each do |file|
        sql = File.read(file)
        @db.exec(sql)
      end
    end

  end
end
