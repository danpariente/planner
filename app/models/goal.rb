class Goal < ApplicationRecord
  belongs_to :account
  default_scope { order(:position, :id) }
end
