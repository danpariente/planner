class SessionsController < ApplicationController
  allow_unauthenticated_access

  # Paso 1: formulario de email.
  def new
    redirect_to root_path if current_account
  end

  # Paso 1b: enviar el magic link + código (si el email está autorizado).
  def create
    if (account = Account.allowed(params[:email]))
      token = account.issue_login_token!
      SessionMailer.magic_link(token).deliver_later
    end
    # Mensaje genérico (no revelamos si el email existe).
    redirect_to login_code_path(email: params[:email].to_s.strip),
                notice: "Si el email está autorizado, te enviamos un enlace y un código de 6 dígitos. Revisa tu correo."
  end

  # Paso 2 (código): formulario para teclear el OTP.
  def code
    @email = params[:email].to_s
  end

  # Paso 2b: verificar el código OTP.
  def verify_code
    if (account = LoginToken.verify_code(params[:email], params[:code]))
      sign_in(account)
      redirect_to root_path, flash: { welcome: "¡Dentro!" }
    else
      flash.now[:alert] = "Código inválido o expirado."
      @email = params[:email].to_s
      render :code, status: :unprocessable_entity
    end
  end

  # Acceso por magic link.
  def magic
    if (lt = LoginToken.find_by_link(params[:token]))
      lt.consume!
      sign_in(lt.account)
      redirect_to root_path, flash: { welcome: "¡Dentro!" }
    else
      redirect_to login_path, alert: "El enlace no es válido o expiró. Pide uno nuevo."
    end
  end

  def destroy
    sign_out
    redirect_to login_path, notice: "Sesión cerrada."
  end
end
