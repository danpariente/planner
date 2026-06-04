class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_authentication

  private

  def require_authentication
    Current.user = User.find_by(id: session[:user_id])
    redirect_to login_path unless Current.user
  end

  # Para que SessionsController abra el acceso a sus propias acciones.
  def self.allow_unauthenticated_access(**options)
    skip_before_action :require_authentication, **options
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
    Current.user = user
  end

  def sign_out
    reset_session
    Current.user = nil
  end

  helper_method def current_user = Current.user
end
