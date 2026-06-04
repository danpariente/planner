class PlanItem < ApplicationRecord
  belongs_to :day, inverse_of: :plan_items
  def color = Category.hex(category) || "#64748b"
end
