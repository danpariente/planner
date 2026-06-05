class MonthsController < ApplicationController
  def show
    @period = params[:period].presence || Date.current.strftime("%Y-%m")
    @first  = Date.strptime(@period, "%Y-%m")
    @notes  = current_account.month_notes.where(on_date: @first..@first.end_of_month).index_by(&:on_date)
    @todos  = current_account.month_todos.for_period(@period)
  end

  def update_note
    note = current_account.month_notes.find_or_initialize_by(on_date: Date.iso8601(params[:on_date].to_s))
    note.body = params[:body]
    note.save!
    head :no_content
  rescue ArgumentError
    head :bad_request
  end
end
