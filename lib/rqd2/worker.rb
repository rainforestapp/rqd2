module Rqd2
  class Worker
    def initialize
    end

    def run_job()
      Rqd2.dequeue do |job|
        ap job
        args = JSON.parse(job['args'])

        Kernel.const_get(job['klass']).send(:perform, *args)
      end
    end
  end
end