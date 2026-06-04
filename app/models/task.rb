class Task < ApplicationRecord
  default_scope { order(:position, :id) }
  scope :by_deadline, -> { reorder(Arel.sql("due_on IS NULL, due_on ASC")) }
end
