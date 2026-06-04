class MonthTodosController < ApplicationController
  def create
    @period = params[:period]
    next_position = (MonthTodo.where(period: @period).maximum(:position) || -1) + 1
    @todo = MonthTodo.create!(period: @period, body: "", position: next_position)
  end

  def update
    @todo = MonthTodo.find(params[:id])
    @todo.update!(params.require(:month_todo).permit(:body, :done))
    head :no_content
  end

  def destroy
    @todo = MonthTodo.find(params[:id])
    @todo.destroy
  end
end
