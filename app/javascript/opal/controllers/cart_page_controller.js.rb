class CartPageController < Stimulus::Controller
  self.targets = [:update_button]

  actions do
    def set_quantity_to_zero(e)
      element.query_selector("##{e.params[:quantityId]}").set_attribute('value', 0)
    end

    def disable_update_button
      update_button_target.set_attribute('disabled', true)
    end
  end
end
