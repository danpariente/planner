class SettingsController < ApplicationController
  # Autosave del D-day de la cuenta.
  def update_target
    date = params[:target_date].presence && Date.iso8601(params[:target_date])
    current_account.update!(target_date: date)
    head :no_content
  rescue ArgumentError
    head :bad_request
  end
end
