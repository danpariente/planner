class SessionMailer < ApplicationMailer
  def magic_link(login_token)
    @token = login_token
    @user  = login_token.user
    @url   = magic_login_url(token: login_token.token)
    @code  = login_token.code
    mail to: @user.email, subject: "Tu acceso a Planner (#{@code})"
  end
end
