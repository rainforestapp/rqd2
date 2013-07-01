module Rqd2
  class Worker

    def initialize
    end

    def run_job(queue = nil)
      job = Rqd2.dequeue(queue)

      # Return if there are no jobs to run
      return :no_jobs unless job

      args = JSON.parse(job['args'])

      Kernel.const_get(job['klass']).send(:perform, *args)

      return :success
    rescue Exception => e # Name Later
      Rqd2.logger.error e.message
      return :failure
    end
  end

  def start(queue = nil)
    while true
      run_job(queue)
    end
  end
end
