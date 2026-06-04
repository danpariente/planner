class TimetableCell < ApplicationRecord
  ROWS = (0..10).to_a
  COLS = %w[Lun Mar Mié Jue Vie].freeze

  def self.grid
    cells = all.index_by { |c| [c.row, c.col] }
    ROWS.map { |r| COLS.each_index.map { |c| cells[[r, c]]&.body.to_s } }
  end

  # Upsert de una celda. Si queda en blanco, se borra la fila en vez de
  # guardar registros vacíos.
  def self.write(row, col, body)
    body = body.to_s.strip
    if body.empty?
      where(row: row, col: col).delete_all
    else
      find_or_initialize_by(row: row, col: col).update!(body: body)
    end
  end
end
