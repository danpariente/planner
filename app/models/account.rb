require "securerandom"

# Una cuenta = un planner independiente. Lista blanca de emails permitidos.
class Account < ApplicationRecord
  has_many :login_tokens,    dependent: :destroy
  has_many :days,            dependent: :destroy
  has_many :priorities,      through: :days
  has_many :plan_items,      through: :days
  has_many :month_notes,     dependent: :destroy
  has_many :month_todos,     dependent: :destroy
  has_many :timetable_cells, dependent: :destroy
  has_many :goals,           dependent: :destroy
  has_many :tasks,           dependent: :destroy
  has_many :materials,       dependent: :destroy
  has_many :categories,      dependent: :destroy

  normalizes :email, with: ->(e) { e.to_s.strip.downcase }
  validates :email, presence: true, uniqueness: true

  after_create_commit :seed_default_categories

  # Solo emails ya presentes pueden entrar (lista blanca cerrada).
  def self.allowed(email) = find_by(email: email.to_s.strip.downcase)

  # Token de acceso (código OTP + token de enlace), invalidando los previos.
  def issue_login_token!
    login_tokens.where(used_at: nil).update_all(used_at: Time.current)
    login_tokens.create!(
      code:       format("%06d", SecureRandom.random_number(1_000_000)),
      token:      SecureRandom.urlsafe_base64(32),
      expires_at: 15.minutes.from_now
    )
  end

  def day_for(date) = days.find_or_create_by!(date: date)

  # Color libre de la paleta para una categoría nueva de esta cuenta.
  def next_category_hex
    used = categories.pluck(:hex)
    Category::PALETTE.find { |h| used.exclude?(h) } || Category::PALETTE[categories.count % Category::PALETTE.size]
  end

  def next_category_position = (categories.maximum(:position) || -1) + 1

  # Categorías por defecto al crear la cuenta (paleta 和色).
  def seed_default_categories
    return if categories.exists?
    Category::DEFAULTS.each_with_index do |(key, name, hex), i|
      categories.create!(key: key, name: name, hex: hex, position: i)
    end
  end
end
