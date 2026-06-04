class GoalsController < ApplicationController
  def index
    @goals = Goal.all
  end

  def create
    @goal = Goal.create!(position: (Goal.maximum(:position) || -1) + 1)
  end

  def update
    @goal = Goal.find(params[:id])
    @goal.update!(params.require(:goal).permit(:area, :target, :previous, :achieved, :done))
    head :no_content
  end

  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy
  end
end
