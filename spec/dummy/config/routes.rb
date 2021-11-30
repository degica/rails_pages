require 'rails_pages/routes'

Rails.application.routes.draw do
  mount_pages RailsPages::Page.all, to: 'pages'
end
