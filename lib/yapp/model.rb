require 'yapp/field'
require 'yapp/model/definition'
require 'yapp/model/parsing'
module YAPP
  class Model
    attr_accessor :children, :fields, :name, :matcher, :options, :parent, :formatters
    attr_reader :acc_length, :template, :line_pre_handler

    include Definition
    include Parsing

    def initialize(template, model_name, matcher, parent, options ={})
      @template = template
      @first_char_at = template.root.first_char rescue 0
      @acc_length = 0
      @children, @fields, @formatters = {}, {}, {}
      @name, @matcher, @parent, @options = model_name, matcher, parent, options
    end
  end
end
