class PlanItem < ApplicationRecord
  belongs_to :day, inverse_of: :plan_items

  def color = day.account.categories.find_by(key: category)&.hex || "#64748b"
end
