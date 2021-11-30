# frozen_string_literal: true

module RailsPages
  # A Page is not actually a database model, but it can be iterated like a
  # database model.
  #
  # An instance of Page is like a controller+view pair. They live in app/pages/.
  #
  # .
  # └── app
  #    └── pages
  #       └── my_page
  #          ├── page.rb
  #          └── page.vue
  #
  # # pages/my_page/page.rb
  # Page.define '/actual/url/path/here' do
  #   data do
  #     { value: 'hello!' } # <- can use in page.vue
  #   end
  # end
  #
  # # pages/my_page/page.vue
  # <template>
  #   <h1>{{ value }}</h1>
  # </template>
  # <script>
  # export default {
  #   data() { return { value: '' } } // <- comes directly from page.rb
  # }
  # </script>
  #
  # In the above example, the name of the page is "my_page". The definitions
  # must be in a pair of files called "page.rb" and "page.vue". Files of other
  # names are ignored.
  class Page
    def self.all
      Loader.lazy_load_pages.values
    end

    def self.each(&block)
      all.each(&block)
    end

    def self.find(id)
      Loader.lazy_load_pages[id]
    end

    def self.find_by(query = {})
      all.find do |page|
        query.keys.all? { |key| page.metadata[key] == query[key] }
      end
    end

    def self.where(query = {})
      all.select do |page|
        (block_given? ? yield(page) : true) &&
          query.keys.all? { |key| page.metadata[key] == query[key] }
      end
    end

    def self.define(route, **metadata, &block)
      Loader.last_definition = [route, block, metadata]
    end

    # -- bookkeeping -- #

    attr_reader :id, :route, :metadata

    def initialize(id, route, block, metadata = nil)
      @id = id
      @route = route
      @block = block
      @metadata = (metadata || {}).with_indifferent_access
    end

    def inspect
      "#<#{self.class.name}:#{id}>"
    end

    def infect(target)
      target.instance_exec do
        @before_blocks = []
        @authorize_blocks = []
        @data_block = proc { }
        @get_blocks = {}
        @post_blocks = {}
      end
      target.instance_exec(&@block)
    end

    # -- DSL methods -- #

    module DSL
      extend ActiveSupport::Concern

      included do
        attr_reader :before_blocks, :authorize_blocks, :data_block, :get_blocks, :post_blocks
      end

      def before(&block)
        @before_blocks << block
      end

      def authorize(&block)
        @authorize_blocks << block
      end

      def data(&block)
        if block
          @data_block = block
        else
          @data_block.call
        end
      end

      def get(action_name, &block)
        @get_blocks[action_name] = block
      end

      def post(action_name, &block)
        @post_blocks[action_name] = block
      end
    end
  end
end
