# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: '_lifeboard_session',
  same_site: :lax,
  secure: Rails.env.production?,
  httponly: true
