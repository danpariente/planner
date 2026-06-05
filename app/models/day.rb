class Day < ApplicationRecord
  SLOT_COUNT = 24
  SLOT_START = 4   # la primera casilla representa las 04:00

  belongs_to :account
  has_many :priorities, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :day
  has_many :plan_items, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :day

  validates :date, presence: true, uniqueness: { scope: :account_id }
  validates :stars, inclusion: { in: 0..5 }

  # Devuelve siempre un array de 24 (rellena con nil).
  def slots
    raw = super || []
    Array.new(SLOT_COUNT) { |i| raw[i] }
  end

  def real_hours = slots.compact.size
end
