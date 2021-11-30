# frozen_string_literal: true

module RailsPages
  module ApplicationHelper
    def rails_pages_entrypoint
      render partial: 'rails_pages/entrypoint'
    end
  end
end
