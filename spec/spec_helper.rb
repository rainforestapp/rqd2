require 'rqd2'

class MyJob
  @queue = :test
end

class MyOtherJob
  @queue = :test2
end

ENV['DATABASE_URL'] = "postgres://postgres:@localhost/rqd2_test"

RSpec.configure do |config|
  config.before(:suite) do
    # Setup Rqd2
    connection = Rqd2.connection
    connection.drop_schema
    connection.setup_schema
  end

  config.before(:each) do
    Rqd2.connection.exec "TRUNCATE TABLE rqd2_jobs"
  end
  # config.before(:each) do
  #   connection = Rqd2.connection
  #   connection.exec("BEGIN")
  # end

  # config.after(:each) do
  #   connection = Rqd2.connection
  #   connection.exec("ROLLBACK")
  # end

  config.filter_run_excluding(performance: true) unless ENV['PERFORMANCE'] != nil
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
