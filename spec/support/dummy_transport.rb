class DummyTransport
  attr_accessor :block

  def initialize(server, options={}, &block)
    @block = block
  end

  def connect!
  end
end
