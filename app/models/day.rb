class Day < ApplicationRecord
  SLOT_COUNT = 24
  SLOT_START = 4   # la primera casilla representa las 04:00

  belongs_to :account
  has_many :priorities, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :day
  has_many :plan_items, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :day

  validates :date, presence: true, uniqueness: { scope: :account_id }
  validates :stars, inclusion: { in: 0..5 }

  # Devuelve siempre un array de 24 (rellena con nil).
  def slots
    raw = super || []
    Array.new(SLOT_COUNT) { |i| raw[i] }
  end

  def real_hours = slots.compact.size

  def past? = date < Date.current

  # Lo que el día dejó sin hacer: filas sin marcar y con texto (las vacías, que
  # son solo huecos del formulario, no se arrastran).
  def pending_priorities = priorities.reject { |p| p.done? || p.body.blank? }
  def pending_plan_items = plan_items.reject { |i| i.done? || i.body.blank? }
  def pending_count = pending_priorities.size + pending_plan_items.size

  # Copia lo pendiente al día `target`, omitiendo lo que ya existe allí (así
  # pulsar el botón dos veces no duplica). Devuelve cuántas filas copió de cada
  # lista. El día original conserva sus pendientes.
  def copy_pending_to(target)
    { priorities: copy_rows(pending_priorities, target.priorities, :body),
      plan_items: copy_rows(pending_plan_items, target.plan_items, :category, :body) }
  end

  private

  # Añade `rows` al final de `collection`, saltando las de firma repetida.
  def copy_rows(rows, collection, *fields)
    seen     = collection.map { |row| signature(row, fields) }
    position = (collection.maximum(:position) || -1) + 1
    copied   = 0
    rows.each do |row|
      next if seen.include?(signature(row, fields))
      seen << signature(row, fields)
      collection.create!(row.slice(*fields).merge("done" => false, "position" => position))
      position += 1
      copied   += 1
    end
    copied
  end

  # Dos filas son "la misma" si coinciden en texto (y categoría), sin fijarse
  # en espacios ni mayúsculas.
  def signature(row, fields) = fields.map { |f| row[f].to_s.strip.downcase }
end
