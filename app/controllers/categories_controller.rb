class CategoriesController < ApplicationController
  # Alta "en el momento" desde el dropdown del plan (categoría de la cuenta).
  def create
    @category = current_account.categories.create!(
      key:      Category.generate_key,
      name:     params.dig(:category, :name).to_s,
      hex:      current_account.next_category_hex,
      position: current_account.next_category_position
    )
    render json: { id: @category.id, key: @category.key, name: @category.name, hex: @category.hex }
  end
end
