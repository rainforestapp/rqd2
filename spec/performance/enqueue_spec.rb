require 'benchmark'

describe Rqd2, performance: true do
  context "10k test" do
    before do
      puts Benchmark.measure {
        10_000.times do
          Rqd2.enqueue MyJob, 1, 2, 3
        end
      }
    end

    it "enqueues 10000 jobs" do
      Rqd2.size.should == 10_000
    end

    it "denqueues 10000 jobs" do
      puts Benchmark.measure {
        10_000.times do
          Rqd2.dequeue
        end
      }

      Rqd2.size.should == 0
    end
  end
end