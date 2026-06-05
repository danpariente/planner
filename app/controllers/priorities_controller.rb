class PrioritiesController < ApplicationController
  def create
    @day = current_account.day_for(Date.iso8601(params[:date].to_s))
    @priority = @day.priorities.create!(body: "", position: (@day.priorities.maximum(:position) || -1) + 1)
  rescue ArgumentError
    head :bad_request
  end

  def update
    @priority = current_account.priorities.find(params[:id])
    @priority.update!(priority_params)
    head :no_content
  end

  def destroy
    @priority = current_account.priorities.find(params[:id])
    @priority.destroy
  end

  private

  def priority_params = params.require(:priority).permit(:body, :done)
end
