# frozen_string_literal: true

module RailsPages
  class Page
    # Handles loading the Ruby files for Pages.
    #
    # rubocop:disable Style/GlobalVars
    #
    # We allow global vars here because this module needs to enforce that pages
    # are only loaded once outside of development. Loading pages multiple times
    # in test, for example, can cause bugs with code coverage.
    module Loader
      extend self

      # Load all page.rb Ruby files from disk.
      # @return [Hash{String => Page}]
      def load_pages
        rails_env_sanity_check!
        self.page_blocks = {}

        page_definitions.each do |page_path|
          id = page_path_to_id(page_path)
          route, block, metadata = execute_page_file(page_path)

          page_blocks[id] = Page.new(id, route, block, metadata)
        end

        page_blocks
      end

      # Only loads pages if they haven't been loaded yet.
      # @return [Hash{String => Page}]
      def lazy_load_pages
        (page_blocks || load_pages)
      end

      # @return [Hash{String => Page}]
      def page_blocks
        $page_blocks
      end

      # @param value [Hash{String => Page}]
      # @return [Hash{String => Page}]
      def page_blocks=(value)
        $page_blocks = value
      end

      # @return [Array<String, Proc, Hash>]
      def last_definition
        $last_definition
      end

      # @param value [Array<String, Proc, Hash>]
      # @return [Array<String, Proc, Hash>]
      def last_definition=(value)
        $last_definition = value
      end

      private

      # Sanity check to make sure pages aren't double-loaded in production.
      # Double loading is OK in development for hot code reloading.
      def rails_env_sanity_check!
        return if Rails.env.development?
        return if page_blocks.nil?

        raise "#{self.class.name}#load_pages called multiple times!\n"\
              'Maybe try lazy_load_pages instead.'
      end

      # Executes a page file, returning the route string and definition block.
      # @return [[String, Proc]] Route string and definition block.
      def execute_page_file(page_path)
        load_success = Kernel.load(page_path)
        definition = last_definition

        raise "Failed to load page #{page_path}" unless load_success
        raise "Page at #{page_path} did not define a page" unless definition

        self.last_definition = nil
        definition
      end

      # @return [Array<String>] absolute path to the top-level pages directory.
      def page_base_paths
        # ["/root/app/pages", "/root/drivers/admin/app/pages"]
        Rails.application.config.paths['app']
          .map { |path| Rails.root.join(path.to_s, 'pages') }
      end

      # @return [Array<String>] list of all page paths.
      def page_definitions
        page_base_paths.flat_map do |base_path|
          Dir.glob(File.join(base_path, '**/page.rb'))
        end
      end

      # @return [String] Convert a path from #page_definitions into an ID string.
      def page_path_to_id(page_path)
        # "/root/app/pages/mypage/page.rb" -> "mypage"
        # "/root/drivers/feature1/app/pages/mypage/page.rb" -> "mypage"
        page_base_paths.map do |base_path|
          page_path.sub("#{base_path}/", '').sub(%r{/page\.rb$}, '')
        end.min_by(&:size)
      end
    end
    # rubocop:enable Style/GlobalVars
  end
end
