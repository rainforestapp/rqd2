describe Rqd2 do |d|
  it "Ensure that a pg connection is present" do
    Rqd2::PgConnection.new().db.class.should eq(PG::Connection)
  end

  describe "#enqueue" do
    it "should enqueue jobs and report the size of the queue" do
      Rqd2.enqueue MyJob, 1, 2, 3
      Rqd2.size.should == 1

      Rqd2.enqueue MyJob, 1, 2, 3
      Rqd2.size.should == 2
    end

    it "doesn't count locked jobs" do
      Rqd2.enqueue MyJob, 1, 2, 3
      Rqd2.size.should == 1
      Rqd2.dequeue{}

      Rqd2.size.should == 0
    end

    it "ensure job is enqueued on the right queue" do
      Rqd2.enqueue MyJob, 1, 2, 3
      Rqd2.size.should == 1

      job = Rqd2.dequeue {|job|
        job['q_name'].should == MyJob.instance_variable_get(:@queue).to_s
      }
    end
  end

  describe "#dequeue" do
    context "with a job" do
      before do
        Rqd2.enqueue MyJob, 1, 2, 3
      end

      it "process any next job in all queues" do
        expect {
          Rqd2.dequeue{}.should == :success
        }.to change{ Rqd2.size }.by(-1)
      end

      it "executes a block thats passed" do
        expect { |b| Rqd2.dequeue }.to yield_control
      end

      it "process next job in a specific queue" do
        size = Rqd2.size
        job = Rqd2.dequeue(:test) {|job|
          job.should be_a(Hash)
          job['q_name'].should == MyJob.instance_variable_get(:@queue).to_s
          job['id'].to_i.should be_> 0
        }

        Rqd2.size.should == size - 1
      end

      it "process next job in a specific queue" do
        Rqd2.dequeue(:test2).should == :no_jobs
      end
    end

    it "return nil if queue is empty" do
      Rqd2.dequeue.should == :no_jobs
    end
  end
end
