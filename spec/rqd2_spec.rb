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
  end

  describe "#dequeue" do
    context "with a job" do
      before do
        Rqd2.enqueue MyJob, 1, 2, 3
      end

      it "process the next job in the queue" do
        expect {
          Rqd2.dequeue{}.should == :success
        }.to change{ Rqd2.size }.by(-1)
      end

      it "executes a block thats passed" do
        expect { |b| Rqd2.dequeue }.to yield_control
      end
    end

    it "return nil if queue is empty" do
      Rqd2.dequeue.should == :no_jobs
    end
  end
end
