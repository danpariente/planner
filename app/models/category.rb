require "securerandom"

# Categorías del planner, propias de cada cuenta (tabla `categories`).
# `key` es un slug estable y opaco: lo referencian plan_items.category y day.slots.
class Category < ApplicationRecord
  # Paleta armoniosa (colores tradicionales japoneses 和色). Al crear una
  # categoría se le asigna el primer color libre. Contraste >= 3.0 sobre blanco.
  PALETTE = %w[
    #5b82a8 #5e9c8f #7e974f #7c828c #8c7bb3 #bd7e50
    #9c6f8f #5f8a76 #b07d92 #8a8f5e
  ].freeze

  # Categorías por defecto de una cuenta nueva.
  DEFAULTS = [
    ["cliente",  "Cliente",  "#5b82a8"],
    ["dev",      "Dev",      "#5e9c8f"],
    ["sc",       "SC:BW",    "#7e974f"],
    ["personal", "Personal", "#7c828c"],
    ["estudio",  "Estudio",  "#8c7bb3"],
    ["otro",     "Otro",     "#bd7e50"]
  ].freeze

  belongs_to :account
  default_scope { order(:position, :id) }

  validates :key, presence: true, uniqueness: { scope: :account_id }

  def self.generate_key = "cat-#{SecureRandom.hex(4)}"
end
