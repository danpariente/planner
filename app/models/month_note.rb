class MonthNote < ApplicationRecord
  belongs_to :account
  validates :on_date, presence: true, uniqueness: { scope: :account_id }
end
