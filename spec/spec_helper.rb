require 'rqd2'

RSpec.configure do |config|
  config.before(:suite) do
    # Setup Rqd2
    connection = Rqd2::PgConnection.new()
    connection.drop_schema
    connection.setup_schema
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end