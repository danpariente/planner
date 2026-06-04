class MaterialsController < ApplicationController
  def index
    @materials = Material.all
  end

  def create
    @material = Material.create!(position: (Material.maximum(:position) || -1) + 1)
  end

  def update
    @material = Material.find(params[:id])
    @material.update!(params.require(:material).permit(:title, :done_count, :total_count))
    head :no_content
  end

  def destroy
    @material = Material.find(params[:id])
    @material.destroy
  end
end
