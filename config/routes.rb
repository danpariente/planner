Rails.application.routes.draw do
  # Health check (lo usa kamal-proxy / load balancers): 200 si la app responde.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA (instalable + offline): manifest, service worker y página sin conexión.
  get "manifest"       => "pwa#manifest",       as: :pwa_manifest
  get "service-worker" => "pwa#service_worker", as: :pwa_service_worker
  get "offline"        => "pwa#offline",        as: :pwa_offline

  # Autenticación: magic link + código OTP (mono-usuario, sin contraseñas).
  get    "login",        to: "sessions#new"
  post   "login",        to: "sessions#create"
  get    "login/code",   to: "sessions#code",        as: :login_code
  post   "login/code",   to: "sessions#verify_code"
  get    "login/l/:token", to: "sessions#magic",     as: :magic_login
  delete "logout",       to: "sessions#destroy",     as: :logout

  root "days#show"

  # Día (por fecha). Sin :date => hoy.
  constraints date: /\d{4}-\d{2}-\d{2}/ do
    get   "day/:date", to: "days#show",   as: :day
    patch "day/:date", to: "days#update"
  end

  resources :priorities,  only: %i[create update destroy]
  resources :plan_items,  only: %i[create update destroy]

  get   "month(/:period)", to: "months#show", as: :month, constraints: { period: /\d{4}-\d{2}/ }
  patch "month_note",      to: "months#update_note"
  resources :month_todos,  only: %i[create update destroy]

  get   "timetable", to: "timetables#show"
  patch "timetable", to: "timetables#update"

  # D-day global (fecha objetivo única para todos los días)
  patch "d_day", to: "settings#update_target", as: :d_day

  resources :goals,      only: %i[index create update destroy]
  resources :tasks,      only: %i[index create update destroy]
  resources :materials,  only: %i[index create update destroy]

  # Alta "en el momento" desde el dropdown del plan (devuelve JSON).
  resources :categories, only: %i[create]
end
