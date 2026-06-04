class User < ApplicationRecord
  has_many :login_tokens, dependent: :destroy

  normalizes :email, with: ->(e) { e.to_s.strip.downcase }
  validates :email, presence: true, uniqueness: true

  # Solo los emails ya presentes en la tabla pueden entrar (lista permitida).
  def self.allowed(email) = find_by(email: email.to_s.strip.downcase)

  # Crea un token de acceso (código OTP + token de enlace), invalidando los previos.
  def issue_login_token!
    login_tokens.where(used_at: nil).update_all(used_at: Time.current)
    login_tokens.create!(
      code:       format("%06d", SecureRandom.random_number(1_000_000)),
      token:      SecureRandom.urlsafe_base64(32),
      expires_at: 15.minutes.from_now
    )
  end
end
