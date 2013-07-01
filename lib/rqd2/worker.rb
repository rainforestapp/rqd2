module Rqd2
  class Worker

    def initialize
    end

    def run_job()
      job = Rqd2.dequeue

      # Return if there are no jobs to run
      return :no_jobs unless job

      args = JSON.parse(job['args'])

      Kernel.const_get(job['method']).send(:perform, *args)

      return :success
    rescue Exception # Name Later
      return :failure
    end
  end
end
