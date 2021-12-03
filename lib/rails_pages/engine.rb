module RailsPages
  class Engine < ::Rails::Engine
    isolate_namespace RailsPages

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'rails_pages.zeitwerk' do
      Rails.application.config.paths['app'].each do |app_path|
        Rails.autoloaders.each do |loader|
          loader.ignore File.join(app_path, 'pages')
        end
      end
    end
  end
end
