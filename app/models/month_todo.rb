class MonthTodo < ApplicationRecord
  belongs_to :account
  scope :for_period, ->(p) { where(period: p).order(:position, :id) }
  validates :period, presence: true
end
