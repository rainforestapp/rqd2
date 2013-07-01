require "rqd2/version"
require "json/ext"
require "rqd2/pg_connection"
require "rqd2/job"
require "rqd2/worker"
require "logger"

module Rqd2
  def self.connection
    @connection ||= Rqd2::PgConnection.new
  end

  def self.connection=(c)
    @connection = Rqd2::PgConnection.new(c)
  end

  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end

  def self.logger= (l)
    @logger = l
  end

  def self.enqueue(klass, *args)
    queue = klass.instance_variable_get(:@queue)
    connection.exec "INSERT INTO rqd2_jobs(q_name, klass, args) VALUES('#{queue}', '#{klass.to_s}', '#{args.to_json}')"
  end

  def self.size
    connection.exec("SELECT COUNT(1) as job_count FROM rqd2_jobs WHERE locked_at IS NULL").first['job_count'].to_i
  end

  def self.dequeue(queue = nil)
    if queue
      queue = Array(queue).map { |x| "'#{x}'" }.join(',')
      queue = "AND q_name IN (#{queue})"
    end

    connection.exec("SAVEPOINT rqd2_dequeue")
    job = connection.exec("SELECT * FROM rqd2_jobs WHERE locked_at IS NULL #{queue} LIMIT 1 FOR UPDATE").first

    if job
      job_id = job['id']

      begin
        connection.exec("UPDATE rqd2_jobs SET locked_at = NOW(), locked_by = #{$$} WHERE id = #{job_id}")
        job['locked_by'] = $$ # Mark as locked by the current process id

        result = yield job

        connection.exec("DELETE FROM rqd2_jobs WHERE id = #{job_id}")
        result = :success
      rescue Exception => e
        connection.exec("UPDATE rqd2_jobs SET failed_at = NOW() WHERE id = #{job_id}")
        Rqd2.logger.error e.message
        Rqd2.requeue_job(job)
        result = :failure
      end

      connection.exec("RELEASE SAVEPOINT rqd2_dequeue")
      result
    else
      return :no_jobs
    end
  end

  def self.requeue_job(hash = {})
    raise "Missing queue name" unless hash['q_name']
    raise "Missing attempts" unless hash['attempts']
    raise "Missing klass" unless hash['klass']
    raise "Missing arguments" unless hash['args']

    hash['attempts'] = hash['attempts'].to_i + 1

    connection.exec "INSERT INTO rqd2_jobs(q_name, klass, args, attempts) VALUES('#{hash['q_name']}', '#{hash['klass']}', '#{hash['args']}', '#{hash['attempts']}')"
  end
end
