class TimetableCell < ApplicationRecord
  ROWS = (0..10).to_a
  COLS = %w[Lun Mar Mié Jue Vie].freeze

  belongs_to :account

  def self.grid_for(account)
    cells = account.timetable_cells.index_by { |c| [c.row, c.col] }
    ROWS.map { |r| COLS.each_index.map { |c| cells[[r, c]]&.body.to_s } }
  end

  # Upsert de una celda de la cuenta. Si queda en blanco, se borra la fila.
  def self.write(account, row, col, body)
    body = body.to_s.strip
    if body.empty?
      account.timetable_cells.where(row: row, col: col).delete_all
    else
      account.timetable_cells.find_or_initialize_by(row: row, col: col).update!(body: body)
    end
  end
end
