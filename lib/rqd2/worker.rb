module Rqd2
  class Worker
    def initialize
    end

    def run_job(queue = nil)
      Rqd2.dequeue(queue) do |job|
        begin
          args = JSON.parse(job['args'])

          Kernel.const_get(job['klass']).send(:perform, *args)

          return :success
        rescue Exception => e # Name Later
          Rqd2.logger.error e.message
          Rqd2.requeue_job(job)
          return :failure
        end
      end
    end
  end

  def start(queue = nil)
    while true
      run_job(queue)
    end
  end
end
