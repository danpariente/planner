class LoginToken < ApplicationRecord
  MAX_ATTEMPTS = 5

  belongs_to :user

  scope :usable, -> { where(used_at: nil).where("expires_at > ?", Time.current) }

  def self.find_by_link(token) = usable.find_by(token: token.to_s)

  # Verifica un código OTP para un email dado. Devuelve el user o nil.
  # Cuenta intentos y quema el token al exceder el máximo.
  def self.verify_code(email, code)
    user = User.allowed(email)
    return nil unless user

    lt = user.login_tokens.usable.order(created_at: :desc).first
    return nil unless lt

    if ActiveSupport::SecurityUtils.secure_compare(lt.code, code.to_s.strip)
      lt.consume!
      user
    else
      lt.increment!(:attempts)
      lt.update!(used_at: Time.current) if lt.attempts >= MAX_ATTEMPTS
      nil
    end
  end

  def consume! = update!(used_at: Time.current)
end
