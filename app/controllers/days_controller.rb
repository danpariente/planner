class DaysController < ApplicationController
  def show
    @day = Day.for(parse_date(params[:date]))
    @categories = Category.all
    @target = Setting.target_date          # D-day global
  end

  # Autosave del bloque "balance" (goal_hours, stars, notes) y del pintado de
  # barras (slots) — ambos PATCH al mismo Day. (El D-day es global: SettingsController.)
  def update
    @day = Day.for(parse_date(params[:date]))
    @day.update!(day_params)
    respond_to do |format|
      format.turbo_stream { head :no_content }
      format.json { render json: { real_hours: @day.real_hours } }
      format.html { redirect_to day_path(@day.date) }
    end
  end

  private

  def parse_date(str)
    Date.iso8601(str.to_s)
  rescue ArgumentError
    Date.current
  end

  def day_params
    params.require(:day).permit(:goal_hours, :stars, :notes, slots: [])
  end
end
