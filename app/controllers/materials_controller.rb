class MaterialsController < ApplicationController
  def index
    @materials = current_account.materials
  end

  def create
    @material = current_account.materials.create!(position: (current_account.materials.maximum(:position) || -1) + 1)
  end

  def update
    @material = current_account.materials.find(params[:id])
    @material.update!(params.require(:material).permit(:title, :done_count, :total_count))
    head :no_content
  end

  def destroy
    @material = current_account.materials.find(params[:id])
    @material.destroy
  end
end
