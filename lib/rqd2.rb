require "rqd2/version"
require "json/ext"
require "rqd2/pg_connection"
require "rqd2/job"
require "rqd2/worker"


module Rqd2
  def self.connection
    @connection ||= Rqd2::PgConnection.new()
  end

  def self.enqueue(klass, *args)
    connection.exec "INSERT INTO rqd2_jobs(klass, args) VALUES('#{klass.to_s}', '#{args.to_json}')"
  end

  def self.size
    connection.exec("SELECT COUNT(1) as job_count FROM rqd2_jobs").first['job_count'].to_i
  end

  def self.dequeue
    job = connection.exec("SELECT * FROM rqd2_jobs LIMIT 1").first
    return unless job

    job_id = job['id']

    connection.exec("DELETE FROM rqd2_jobs WHERE id = #{job_id}")
    job
  end
end
