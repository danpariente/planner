class PwaController < ApplicationController
  allow_unauthenticated_access

  def manifest
    render template: "pwa/manifest", formats: :json, content_type: "application/manifest+json"
  end

  def service_worker
    expires_in 1.hour, public: true
    render plain: Rails.root.join("app/views/pwa/service-worker.js").read,
           content_type: "text/javascript"
  end

  private

  # Los archivos PWA son públicos y se sirven a sí mismos; desactivamos el
  # chequeo cross-origin de JS que, si no, bloquea servir el service worker.
  def verify_same_origin_request; end
end
