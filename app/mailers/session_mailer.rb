class SessionMailer < ApplicationMailer
  def magic_link(login_token)
    @token   = login_token
    @account = login_token.account
    @url     = magic_login_url(token: login_token.token)
    @code    = login_token.code
    # El correo sale en el idioma preferido de la cuenta.
    I18n.with_locale(@account.locale) do
      mail to: @account.email, subject: t("session_mailer.magic_link.subject", code: @code)
    end
  end
end
