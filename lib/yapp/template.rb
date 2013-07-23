require 'stringio'
require 'active_support'
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


    def parse(parsable, &callback)
      io = to_io(parsable)
      result = @root.parse(io, nil, nil, callback)
      io.close if io.respond_to? 'close'
      callback ? nil : result[:children] 
    end

    protected
    def to_io(parsable)
      return parsable if parsable.is_a? IO
      return parsable if parsable.is_a? StringIO
      return ArgumentError, "Don't know how to parse a #{parsable.class.name}" unless parsable.is_a? String
      return File.open(parsable, 'rb') if File.exists?(parsable)
      StringIO.new(parsable)
    end
  end
end


