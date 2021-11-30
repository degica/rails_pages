module RailsPages
  module ControllerActions
    extend ActiveSupport::Concern
    include Page::DSL

    included do
      before_action :fetch_page
      before_action :run_page_hooks
    end

    def page
      @data = data_block.call

      respond_to do |format|
        format.html { render }
        format.json { render json: @data }
      end
    end

    def page_get
      run_action_block(get_blocks)
    end

    def page_post
      run_action_block(post_blocks)
    end

    private

    def fetch_page
      @page = Page.find(params[:page_id])
      raise Errors::NotFound if @page.nil?

      @page.infect(self)
    end

    def run_page_hooks
      before_blocks.each(&:call)

      if authorize_blocks.empty?
        raise "Page missing authorization: #{@page.id}"
      end

      authorize_blocks.each do |block|
        next if block.call
        raise Errors::Unauthorized
      end
    end

    def run_action_block(blocks)
      block = blocks[params[:action_name]]
      raise Errors::NotFound if block.nil?
      block.call
    end
  end
end
