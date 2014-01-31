require 'stringio'
require 'core_ext'
require 'yapp/exceptions'
require 'yapp/field'
require 'yapp/model'

module YAPP
  class Template
    attr_accessor :root
    def initialize(&block)
      @root = Model.new(self, nil, nil, nil)
      block.arity < 1 ? @root.instance_eval(&block) : block.call(@root) if block_given?
    end


    def parse(parseable, generator=nil, &callback)
      io = to_io(parseable)
      result = @root.parse(io, nil, generator, callback)
      io.close if io.respond_to? 'close'
      result
    end

    protected
    def to_io(parseable)
      return parseable if parseable.is_a? IO
      return parseable if parseable.is_a? StringIO
      return ArgumentError, "Don't know how to parse a #{parseable.class.name}" unless parseable.is_a? String
      return File.open(parseable, 'rb') if File.exists?(parseable)
      StringIO.new(parseable)
    end
  end
end


