module Rqd2
  class Worker
    def initialize
    end

    def run_job(queue = nil)
      Rqd2.dequeue(queue) do |job|
        args = JSON.parse(job['args'])

        Kernel.const_get(job['klass']).send(:perform, *args)
      end
    end
  end

  def start(queue = nil)
    while true
      run_job(queue)
    end
  end
end