class CategoriesController < ApplicationController
  # Alta "en el momento" desde el dropdown del plan. Clave auto-generada (slug
  # estable), color tomado de la paleta armoniosa. Responde JSON para que el
  # controlador Stimulus inserte la nueva opción y la seleccione.
  def create
    @category = Category.create!(
      key:      Category.generate_key,
      name:     params.dig(:category, :name).to_s,
      hex:      Category.next_hex,
      position: Category.next_position
    )
    render json: { id: @category.id, key: @category.key, name: @category.name, hex: @category.hex }
  end
end
