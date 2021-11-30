module RailsPages
  # These errors are typically raised by RailsPages::ControllerActions.
  module Errors
    # Raised when a page or page action was not found.
    class NotFound < StandardError
    end

    # Raised when a page's authorize block returns false.
    class Unauthorized < StandardError
    end
  end
end
