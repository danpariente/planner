class PlanItemsController < ApplicationController
  def create
    @day = current_account.day_for(Date.iso8601(params[:date].to_s))
    @plan_item = @day.plan_items.create!(category: current_account.categories.first&.key, body: "",
                                         position: (@day.plan_items.maximum(:position) || -1) + 1)
  rescue ArgumentError
    head :bad_request
  end

  def update
    @plan_item = current_account.plan_items.find(params[:id])
    @plan_item.update!(plan_item_params)
    head :no_content
  end

  def destroy
    @plan_item = current_account.plan_items.find(params[:id])
    @plan_item.destroy
  end

  private

  def plan_item_params = params.require(:plan_item).permit(:category, :body, :done)
end
