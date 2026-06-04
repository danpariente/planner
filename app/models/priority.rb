class Priority < ApplicationRecord
  belongs_to :day, inverse_of: :priorities
end
