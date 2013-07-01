require 'rqd2'

namespace :rqd2 do
  desc "Work"
  task :work do

    handler = -> (*args) do
      Rails.logger.info "Stopping RQD2."
      stop = true
    end

    trap("INT", handler)
    trap("TERM", handler)

    Rqd2::Worker.new.start(nil, lambda { stop })
  end

  desc "Install"
  task :install do
    Rqd2::PgConnection.new().setup_schema()
  end

  desc "Remove"
  task :remove do
    Rqd2::PgConnection.new().drop_schema()
  end
end