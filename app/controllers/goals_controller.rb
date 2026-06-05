class GoalsController < ApplicationController
  def index
    @goals = current_account.goals
  end

  def create
    @goal = current_account.goals.create!(position: (current_account.goals.maximum(:position) || -1) + 1)
  end

  def update
    @goal = current_account.goals.find(params[:id])
    @goal.update!(params.require(:goal).permit(:area, :target, :previous, :achieved, :done))
    head :no_content
  end

  def destroy
    @goal = current_account.goals.find(params[:id])
    @goal.destroy
  end
end
