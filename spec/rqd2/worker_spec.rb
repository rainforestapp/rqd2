class MyJob
  def self.perform(a, b, c)
  end
end

describe Rqd2::Worker do |d|
  it "Ensure that a pg connection is present" do
    Rqd2::PgConnection.new().db.class.should eq(PG::Connection)
  end

  describe "#run_job" do
    context "with a job" do
      before do
        Rqd2.enqueue MyJob, 1, 2, 3
      end

      it "process the next job in the queue" do
        Rqd2::Worker.new.run_job.should == :success
      end

      it "calls the perform method with the correct arguments" do
        MyJob.should_receive(:perform).with(1,2,3).once
        Rqd2::Worker.new.run_job
      end
    end

    context "testing run job failure" do
      before do
        Rqd2.enqueue MyJob
      end

      it "process the next job in the queue" do
        Rqd2::Worker.new.run_job.should == :failure
      end
    end

    it "return nil if queue is empty" do
      Rqd2::Worker.new.run_job.should == :no_jobs
    end
  end
end
