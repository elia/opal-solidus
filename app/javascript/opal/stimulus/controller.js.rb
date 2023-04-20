# helpers: slice, prop, send

require 'stimulus/browser'

class Stimulus::Controller
  @__native__ = `class extends window.Stimulus.Controller {}`

  def self.controllers
    @controllers ||= []
  end

  def self.register_all!
    controllers.each(&:register!)
  end

  def self.inherited(subclass)
    ::Stimulus::Controller.controllers << subclass
  end

  def self.stimulus_name
    @stimulus_name ||= name.gsub(/Controller$/, '').gsub(/([a-z])([A-Z])/, '\1-\2').downcase
  end

  def self.__native__
    @__native__ ||= begin
      %x{
        // Use this trick to set the browser display name to the identifier
        const __native__ = {}
        __native__[#{stimulus_name}] = class extends (#{superclass}.__native__) {
          initialize() {
            super.initialize()
            this.$$bridge = #{allocate}
            this.$$bridge.__native__ = this
          }
        }
        __native__[#{stimulus_name}].$$bridge = #{self}
      }

      `__native__[#{stimulus_name}]`
    end
  end

  attr_reader :__native__

  def self.register!(identifier: stimulus_name, application: `window.Stimulus`)
    %x{
      #{__native__}.displayName = #{name} + ' (native)'
      #{application}.register(#{identifier}, #{__native__})
    }
    @__registered__ = true
  end

  def self.define_stimulus_reader(name, &block)
    @method_visibility = :config
    stimulus_name = stimulus_method_name(name)
    if block_given?
      define_method(name) { block.call @__native__.JS[stimulus_name] }
    else
      define_method(name) { @__native__.JS[stimulus_name] }
    end
    @method_visibility = nil
  end

  def self.define_stimulus_writer(name)
    @method_visibility = :config
    stimulus_name = stimulus_method_name(name)
    if block_given?
      define_method("#{name}=") { |value| @__native__.JS[stimulus_name] = block.call(value) }
    else
      define_method("#{name}=") { |value| @__native__.JS[stimulus_name] = value.to_n }
    end
    @method_visibility = nil
  end

  def self.targets=(names)
    __native__.JS[:targets] = names.map { |name| stimulus_method_name(name) }

    names.each do |name|
      define_stimulus_reader "has_#{name}_target?"
      define_stimulus_reader("#{name}_target") { |value| Browser::DOM::Node.new(value) }
      define_stimulus_reader("#{name}_targets") { |values| values.map { Browser::DOM::Node.new(_1) } }
    end
  end

  def self.outlets=(names)
    __native__.JS[:outlets] = names.map { |name| stimulus_method_name(name) }

    names.each do |name|
      define_stimulus_reader "has_#{name}_outlet?"
      define_stimulus_reader "#{name}_outlet"
      define_stimulus_reader "#{name}_outlets"
      define_stimulus_reader "#{name}_outlet_element"
      define_stimulus_reader "#{name}_outlet_elements"
    end
  end

  def self.classes=(names)
    __native__.JS[:classes] = names.map { |name| stimulus_method_name(name) }

    names.each do |name|
      define_stimulus_reader "has_#{name}_class?"
      define_stimulus_reader "#{name}_class"
      define_stimulus_reader "#{name}_classes"
    end
  end

  def self.values=(options = {})
    type_for = ->(type) {
      case type
      when :string then `String`
      when :number then `Number`
      when :boolean then `Boolean`
      when :object then `Object`
      when :array then `Array`
      else type.JS['$$constructor']
      end
    }
    __native__.JS[:values] = options
      .transform_keys { |key| stimulus_method_name(key) }
      .transform_values do |config|
        if config.is_a?(Hash)
          type = config[:type]
          config.merge(type: type_for[type])
        else
          type_for[config]
        end
      end
      .to_n

    options.keys.each do |name|
      define_stimulus_reader "has_#{name}_value?"
      define_stimulus_reader "#{name}_value"
      define_stimulus_writer "#{name}_value"
    end
  end

  def self.stimulus_method_name(string)
    string.gsub(/_([a-z])/) { $1.upcase }.sub(/(\?|\!|\=)$/, '')
  end

  def method_missing(name, *args, &block)
    if @__native__.JS[name]
      args << block if block_given?
      @__native__.JS[name].call(*args)
    else
      super
    end
  end

  def self.method_added(name)
    case @method_visibility
    when :config
      # noop
    when :action
      arity = instance_method(name).arity
      %x{
        if (#{arity} > 0) {
          #{__native__}.prototype[#{stimulus_method_name(name)}] = function(e) {
            return $send(this.$$bridge, name, [#{Browser::Event.new(`e`)}])
          }
        } else {
          #{__native__}.prototype[#{stimulus_method_name(name)}] = function() {
            return $send(this.$$bridge, name)
          }
        }
      }
    else
      %x{
        $prop(#{__native__}.prototype, #{stimulus_method_name(name)}, function(...args) {
          return $send(this.$$bridge, name, args)
        })
      }
    end
  end

  def self.actions
    @method_visibility = :action
    yield
    @method_visibility = nil
  end

  define_stimulus_reader(:element) { |value| Browser::DOM::Node.new(value) }
  define_stimulus_reader(:identifier)
end
