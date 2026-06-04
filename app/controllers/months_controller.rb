class MonthsController < ApplicationController
  def show
    @period = params[:period].presence || Date.current.strftime("%Y-%m")
    @first  = Date.strptime(@period, "%Y-%m")
    @notes  = MonthNote.where(on_date: @first..@first.end_of_month).index_by(&:on_date)
    @todos  = MonthTodo.for_period(@period)
  end

  def update_note
    note = MonthNote.for(Date.iso8601(params[:on_date].to_s))
    note.body = params[:body]
    note.save!
    head :no_content
  rescue ArgumentError
    head :bad_request
  end
end
