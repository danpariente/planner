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

  # "»» a hoy": copia al día actual lo que este día dejó pendiente y te lleva allí.
  def carry_forward
    day   = current_account.day_for(parse_date(params[:date]))
    today = current_account.day_for(Date.current)
    copied = day == today ? { priorities: 0, plan_items: 0 } : day.copy_pending_to(today)
    redirect_to day_path(today.date), notice: carried_notice(copied)
  end

  private

  # "2 prioridades, 1 fila del plan" -> texto del flash.
  def carried_notice(copied)
    parts = copied.filter_map { |list, n| t("days.carry_forward.#{list}", count: n) if n.positive? }
    parts.any? ? t("days.carry_forward.done", items: parts.join(", ")) : t("days.carry_forward.none")
  end

  def parse_date(str)
    Date.iso8601(str.to_s)
  rescue ArgumentError
    Date.current
  end

  def day_params
    params.require(:day).permit(:goal_hours, :stars, :notes, slots: [])
  end
end
