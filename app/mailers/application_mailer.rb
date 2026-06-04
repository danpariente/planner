class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "Planner <login@planner.lifestyle>")
  layout "mailer"
end
