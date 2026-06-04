class PlanItemsController < ApplicationController
  def create
    date = Date.iso8601(params[:date].to_s)
    @day = Day.for(date)
    @plan_item = @day.plan_items.create!(category: Category.first&.key, body: "", position: (@day.plan_items.maximum(:position) || -1) + 1)
  rescue ArgumentError
    head :bad_request
  end

  def update
    @plan_item = PlanItem.find(params[:id])
    @plan_item.update!(plan_item_params)
    head :no_content
  end

  def destroy
    @plan_item = PlanItem.find(params[:id])
    @plan_item.destroy
  end

  private

  def plan_item_params = params.require(:plan_item).permit(:category, :body, :done)
end
