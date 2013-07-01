require "rqd2/version"
require 'json/ext'
require "rqd2/pg_connection"

module Rqd2
  def self.connection
    @connection ||= Rqd2::PgConnection.new()
  end

  # Your code goes here...
  def self.enqueue(klass, *args)
    connection.exec "INSERT INTO rqd2_jobs(method, args) VALUES('#{klass.to_s}', '#{args.to_json}')"
  end

  def self.size
    connection.exec("SELECT COUNT(1) as job_count FROM rqd2_jobs").first['job_count'].to_i
  end
end
