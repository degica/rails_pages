require 'rails_pages/routes'

Rails.application.routes.draw do
  mount_pages RailsPages::Page.all, to: 'pages'
  mount_page_fallback 'page', to: 'pages'
end
