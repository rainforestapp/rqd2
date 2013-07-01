require 'pg'

module Rqd2
  class PgConnection
    attr_accessor :db

    def initialize(connection = nil)
      if connection.is_a?(PG::Connection)
        @db = connection
        return
      end

      @db = PG::Connection.new(normalize_db_url(db_url))
    end

    def setup_schema
      @sqls = File.join(File.dirname(__FILE__), '..', '..', 'sql')
      Dir["#{@sqls}/*.sql"].each do |file|
        sql = File.read(file)
        @db.exec(sql)
      end
    end

    def transaction
      begin
        exec 'BEGIN'
        yield
        exec 'COMMIT'
      rescue
        exec 'ROLLBACK'
      end
    end

    def drop_schema
      @db.exec "DROP TABLE IF EXISTS rqd2_jobs;"
    end

    def exec(sql)
      @db.exec sql
    end

    def normalize_db_url(url)
      host = url.host
      host = host.gsub(/%2F/i, '/') if host

      {
       host: host, # host or percent-encoded socket path
       port: url.port || 5432,
       dbname: url.path.gsub("/",""), # database name
       user: url.user,
       password: url.password
      }
    end

    def db_url
      return @db_url if @db_url
      url = ENV["QC_DATABASE_URL"] ||
            ENV["DATABASE_URL"]    ||
            raise(ArgumentError, "missing QC_DATABASE_URL or DATABASE_URL")
      @db_url = URI.parse(url)
    end
  end
end
