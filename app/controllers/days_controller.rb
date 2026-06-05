class DaysController < ApplicationController
  def show
    @day = current_account.day_for(parse_date(params[:date]))
    @categories = current_account.categories
    @target = current_account.target_date          # D-day de la cuenta
  end

  # Autosave del balance (goal_hours, stars, notes) y del pintado de barras (slots).
  def update
    @day = current_account.day_for(parse_date(params[:date]))
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
