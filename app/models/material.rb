class Material < ApplicationRecord
  belongs_to :account
  default_scope { order(:position, :id) }
  def pct = total_count.to_i.positive? ? (done_count.to_f / total_count * 100).round : 0
end
