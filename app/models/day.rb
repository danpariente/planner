class Day < ApplicationRecord
  SLOT_COUNT = 24
  SLOT_START = 4   # la primera casilla representa las 04:00

  has_many :priorities, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :day
  has_many :plan_items, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :day

  validates :date, presence: true, uniqueness: true
  validates :stars, inclusion: { in: 0..5 }

  # Devuelve siempre un array de 24 (rellena con nil).
  def slots
    raw = super || []
    Array.new(SLOT_COUNT) { |i| raw[i] }
  end

  def real_hours = slots.compact.size

  def self.for(date) = find_or_create_by!(date: date)
end
