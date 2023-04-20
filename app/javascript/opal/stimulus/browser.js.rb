class Stimulus::Params
  def initialize(params)
    @native = params
  end

  def [](key)
    @native.JS[key]
  end
end

# Browser support
require 'native'
require 'promise/v2'
Promise = PromiseV2
require 'browser/setup/base'
require 'browser/event'
require 'browser/window'
require 'browser/dom'

Browser::Event.class_eval do
  def params
    @params ||= ::Stimulus::Params.new(`#@native.params`)
  end
end

Browser::DOM::Element.class_eval do
  def query_selector(selector)
    ::Browser::DOM::Node.new(`#@native.querySelector(#{selector})`)
  end
  
  alias query_selector_all at_css
end

module FormAccessor
  def form
    ::Browser::DOM::Element::Form.new(`#@native.form`)
  end
end

::Browser::DOM::Element::Select.include FormAccessor
::Browser::DOM::Element::Input.include FormAccessor

