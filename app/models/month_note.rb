class MonthNote < ApplicationRecord
  validates :on_date, presence: true, uniqueness: true
  def self.for(date) = find_or_initialize_by(on_date: date)
end
