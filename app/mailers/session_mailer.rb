class SessionMailer < ApplicationMailer
  def magic_link(login_token)
    @token   = login_token
    @account = login_token.account
    @url     = magic_login_url(token: login_token.token)
    @code    = login_token.code
    mail to: @account.email, subject: "Tu acceso a Planner (#{@code})"
  end
end
