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
end
