class HelloController < Stimulus::Controller
  def connect
    element.content = "Hello, Stimulus!"
  end
end
