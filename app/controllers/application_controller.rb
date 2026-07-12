class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_authentication
  around_action :switch_locale

  private

  # ?locale=en|es cambia el idioma: se persiste en la cuenta (si hay sesión)
  # y en session[:locale] (para las páginas de login).
  def switch_locale(&action)
    # En acciones sin autenticación (PWA, logout) require_authentication no
    # corre, pero el idioma de la cuenta debe aplicar igual si hay sesión.
    Current.account ||= Account.find_by(id: session[:account_id])
    if (requested = params[:locale].presence) && I18n.available_locales.map(&:to_s).include?(requested)
      session[:locale] = requested
      current_account&.update!(locale: requested)
    end
    I18n.with_locale(current_account&.locale || session[:locale] || I18n.default_locale, &action)
  end

  def require_authentication
    Current.account = Account.find_by(id: session[:account_id])
    redirect_to login_path unless Current.account
  end

  # Para que SessionsController abra el acceso a sus propias acciones.
  def self.allow_unauthenticated_access(**options)
    skip_before_action :require_authentication, **options
  end

  def sign_in(account)
    locale = session[:locale]
    reset_session
    session[:account_id] = account.id
    Current.account = account
    # El idioma elegido en la página de login pasa a ser el de la cuenta.
    account.update!(locale: locale) if locale && locale != account.locale
  end

  def sign_out
    locale = Current.account&.locale
    reset_session
    session[:locale] = locale if locale
    Current.account = nil
  end

  helper_method def current_account = Current.account
end
