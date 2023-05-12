# await: true

require 'browser/http'

class TopBarController < Stimulus::Controller
  self.targets = [:cart_link]
  self.values = {
    cart_url: String
  }

  actions do
    def update_cart_link
      response = Browser::HTTP.get(cart_url_value).__await__
      cart_link_target.inner_html = response.text
    end
  end

  def connect
    update_cart_link
  end
end
