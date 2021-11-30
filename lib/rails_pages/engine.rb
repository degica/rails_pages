module RailsPages
  class Engine < ::Rails::Engine
    isolate_namespace RailsPages

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
