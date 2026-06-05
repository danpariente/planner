class LoginToken < ApplicationRecord
  MAX_ATTEMPTS = 5

  belongs_to :account

  scope :usable, -> { where(used_at: nil).where("expires_at > ?", Time.current) }

  def self.find_by_link(token) = usable.find_by(token: token.to_s)

  # Verifica un código OTP para un email dado. Devuelve la cuenta o nil.
  def self.verify_code(email, code)
    account = Account.allowed(email)
    return nil unless account

    lt = account.login_tokens.usable.order(created_at: :desc).first
    return nil unless lt

    if ActiveSupport::SecurityUtils.secure_compare(lt.code, code.to_s.strip)
      lt.consume!
      account
    else
      lt.increment!(:attempts)
      lt.update!(used_at: Time.current) if lt.attempts >= MAX_ATTEMPTS
      nil
    end
  end

  def consume! = update!(used_at: Time.current)
end
