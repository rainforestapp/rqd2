class MyJob; ; end;

describe Rqd2 do |d|
  before(:all) do
    connection = Rqd2::PgConnection.new()
    connection.drop_schema
    connection.setup_schema
  end

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
  end

  describe "#dequeue" do
    before do
      Rqd2.enqueue MyJob, 1, 2, 3
    end

    it "process the next job in the queue" do
      size = Rqd2.size
      job = Rqd2.dequeue

      job.should be_a(Hash)
      job['id'].to_i.should be_> 0
      Rqd2.size.should == size - 1
    end

    it "return nil if queue is empty" do
      Rqd2.dequeue.should == nil
    end
  end


end
