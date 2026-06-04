# Ajustes globales de la app (clave/valor). Mono-usuario, así que una fila por
# clave alcanza. Hoy solo guarda el "D-day" global; queda listo para más.
class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.[](key) = find_by(key: key.to_s)&.value

  def self.[]=(key, value)
    find_or_initialize_by(key: key.to_s).update!(value: value)
  end

  # --- D-day global (fecha objetivo única para todos los días) ---
  def self.target_date
    v = self["target_date"]
    Date.iso8601(v) if v.present?
  rescue ArgumentError
    nil
  end

  def self.target_date=(str)
    if str.blank?
      where(key: "target_date").delete_all   # limpiar el objetivo
    else
      self["target_date"] = Date.iso8601(str.to_s).iso8601   # valida y normaliza
    end
  end
end
