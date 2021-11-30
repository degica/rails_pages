module RailsPages
  module Routes
    # @param page [Array<RailsPages::Page>] Page to mount.
    # @param to [String] Controller to use. Action name cannot be specified.
    def mount_pages(pages, to:)
      pages.each { |page| mount_page page, to: to }
    end

    # @param page [RailsPages::Page] Page to mount.
    # @param to [String] Controller to use. Action name cannot be specified.
    def mount_page(page, to:)
      # This is the main route. It includes a route helper based on the page ID.
      get page.route, to: "#{to}#page", page_id: page.id,
        as: "#{page.id.tr('/', '_')}_page"

      # These are used for 'get' and 'post' blocks inside the page definition.
      get "#{page.route}/action/:action_name", to: "#{to}#page_get", page_id: page.id
      post "#{page.route}/action/:action_name", to: "#{to}#page_post", page_id: page.id

      # BTW, all of the above actions are defined in the controller concern
      # RailsPages::ControllerActions
    end

    # This mounts a default route that can be used for all pages.
    # It's mainly useful for test environments.
    def mount_page_fallback(path, to:)
      get path, to: "#{to}#page"
      get File.join(path, 'action'), to: "#{to}#page_get"
      post File.join(path, 'action'), to: "#{to}#page_post"
    end
  end
end

class ActionDispatch::Routing::Mapper
  include RailsPages::Routes
end
