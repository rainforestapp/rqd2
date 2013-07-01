require 'rqd2'

describe Rqd2 do |d|

  it "2 is equal to 2" do
    2.should eq(2)
  end

  it "Ensure that a pg connection is present" do
    Rqd2::PgConnection.new().db.class.should eq(PG::Connection)
  end

end
