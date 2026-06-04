require "securerandom"

# Categorías del planner. Ahora viven en la base de datos (tabla `categories`).
# `key` es un slug estable y opaco: lo referencian plan_items.category y el array
# day.slots, así que renombrar una categoría NO rompe los datos guardados.
class Category < ApplicationRecord
  # Paleta armoniosa (colores tradicionales japoneses 和色). Al crear una
  # categoría se le asigna el primer color libre de esta lista; si ya se usaron
  # todos, se cicla. Todos tienen contraste >= 3.0 sobre blanco.
  PALETTE = %w[
    #5b82a8 #5e9c8f #7e974f #7c828c #8c7bb3 #bd7e50
    #9c6f8f #5f8a76 #b07d92 #8a8f5e
  ].freeze

  default_scope { order(:position, :id) }

  validates :key, presence: true, uniqueness: true

  # Color libre de la paleta (el primero que no esté en uso), o cicla si se
  # agotaron.
  def self.next_hex
    used = pluck(:hex)
    PALETTE.find { |h| used.exclude?(h) } || PALETTE[count % PALETTE.size]
  end

  def self.next_position = (maximum(:position) || -1) + 1

  def self.generate_key = "cat-#{SecureRandom.hex(4)}"

  # --- Interfaz que consumen las vistas / el painter (compatibilidad) ---
  def self.hex(key) = find_by(key: key.to_s)&.hex
  def self.map      = all.to_h { |c| [c.key, c.hex] }   # { slug => hex } para el painter JS
end
