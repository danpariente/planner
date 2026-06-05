class TimetablesController < ApplicationController
  def show
    @grid = TimetableCell.grid_for(current_account)
  end

  def update
    (params[:cells] || {}).each do |key, body|
      row, col = key.split("-").map(&:to_i)
      TimetableCell.write(current_account, row, col, body)
    end
    head :no_content
  end
end
