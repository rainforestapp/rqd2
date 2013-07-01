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
    connection.exec("SELECT COUNT(1) as job_count FROM rqd2_jobs WHERE locked_at IS NULL").first['job_count'].to_i
  end

  def self.dequeue
    connection.exec("SAVEPOINT rqd2_dequeue")
    job = connection.exec("SELECT * FROM rqd2_jobs WHERE locked_at IS NULL LIMIT 1 FOR UPDATE").first

    if job
      job_id = job['id']

      begin
        connection.exec("UPDATE rqd2_jobs SET locked_at = NOW() WHERE id = #{job_id}")

        result = block.call(job)

        connection.exec("DELETE FROM rqd2_jobs WHERE id = #{job_id}")
        result = :success
      rescue Exception => e
        connection.exec("UPDATE rqd2_jobs SET failed_at = NOW() WHERE id = #{job_id}")
        result = :failure
      end

      connection.exec("RELEASE SAVEPOINT rqd2_dequeue")
      result
    else
      return :no_jobs
    end
  end
end
