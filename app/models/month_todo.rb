class MonthTodo < ApplicationRecord
  scope :for_period, ->(p) { where(period: p).order(:position, :id) }
  validates :period, presence: true
end
