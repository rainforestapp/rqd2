namespace :rqd2 do
  desc "Work"
  task :work do
    require 'rqd2'

    handler = -> (*args) do
      Rails.logger.info "Stopping RQD2."
      stop = true
    end

    trap("INT", handler)
    trap("TERM", handler)

    Rqd2::Worker.new.start(lambda { stop })
  end
end
