class Goal < ApplicationRecord
  default_scope { order(:position, :id) }
end
