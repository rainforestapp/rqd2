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
    queue = klass.instance_variable_get(:@queue)
    connection.exec "INSERT INTO rqd2_jobs(q_name, klass, args) VALUES('#{queue}', '#{klass.to_s}', '#{args.to_json}')"
  end

  def self.size
    connection.exec("SELECT COUNT(1) as job_count FROM rqd2_jobs").first['job_count'].to_i
  end

  def self.dequeue(queue = nil)

    if queue
      queue = [queue] unless queue.is_a?(Array)
      queue = queue.map { |x| "'#{x}'" }.join(',')
      queue = "WHERE q_name IN (#{queue})"
    end

    job = connection.exec("SELECT * FROM rqd2_jobs #{queue} LIMIT 1").first
    return unless job

    job_id = job['id']

    connection.exec("DELETE FROM rqd2_jobs WHERE id = #{job_id}")
    job
  end
end
