class TimetablesController < ApplicationController
  def show
    @grid = TimetableCell.grid
  end

  # Recibe params[:cells]["row-col"] = body y hace upsert de cada celda.
  def update
    (params[:cells] || {}).each do |key, body|
      row, col = key.split("-").map(&:to_i)
      TimetableCell.write(row, col, body)
    end
    head :no_content
  end
end
