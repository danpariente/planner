class SettingsController < ApplicationController
  # Autosave del D-day global (fecha objetivo única para todos los días).
  def update_target
    Setting.target_date = params[:target_date]
    head :no_content
  rescue ArgumentError
    head :bad_request
  end
end
