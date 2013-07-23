require 'stringio'
require 'active_support'
class Fixnum
  def length
    self
  end
end

class Range
  def length
    self.last - self.first
  end
end

module YAPP

  class LineNotMine < ArgumentError
  end

  class Model
    attr_accessor :children, :fields, :name, :matcher, :options, :parent, :formatters
    attr_reader :acc_length, :template
    def initialize(template, model_name, matcher, parent, options ={})
      @template = template
      @first_char_at = template.root.first_char rescue 0
      @acc_length = 0
      @children, @fields, @formatters = {}, {}, {}
      @name, @matcher, @parent, @options = model_name, matcher, parent, options
    end

    def first_char_at(where)
      @first_char_at = where
    end

    def first_char
      @first_char_at
    end

    def pre_handle_line(&block)
      @line_pre_handler = block
    end

    def model(model_name, matcher, options={}, &block)
      model = Model.new(template, model_name, matcher, self, options)
      block.arity < 1 ? model.instance_eval(&block) : block.call(model) if block_given?
      @children[model.name] = model
    end

    def field(field_name, range, handler_sym_or_proc= nil)
      #field_name = ActiveSupport::Inflector.transliterate(field_name.to_s.strip).underscore.gsub(' ', '_')
      #field_name = ActiveSupport::Inflector.transliterate(field_name.to_s.strip).underscore.gsub(' ', '_')
      field = Field.new(field_name, range, self, handler_sym_or_proc)
      @fields[field.name]=field
      @acc_length += field.length
    end

    def formatter(formatter_sym, &block)
      @formatters[formatter_sym] = block;
    end

    def parse_fields(line)
      line.chomp!
      line = @line_pre_handler.call(line) if @line_pre_handler
      f = {}
      @fields.each do |name, field|
        f[name] = field.get_value(line)
      end
      f
    end

    def get_handler(handler_sym)
      @formatters[handler_sym] || (parent ? parent.get_handler(handler_sym) : nil )
    end

    def parse(io, parent_node, my_line = nil, callback=nil)
      fields = my_line ? parse_fields(my_line) : {}
      curr = { :type => @name, 
        :lineno => io.lineno, 
        :path => [(parent_node ? parent_node[:path] : ''), @name].join('/') ,
        :raw => my_line,
        :parent => parent_node,
        :children => {},
        :model => self
      }
      curr[:fields] = fields if fields.size > 0

      @children.each do |k,v|
            curr[:children]||={}
            curr[:children][v.name] ||=[]
      end

      callback.call(curr) if callback
      io.each_line do |line|
        next if line.strip.size == 0 # XXX...should not do this in strict mode

        loop do
          if m = @children.values.find{|c| c.match? line }
            if _child = m.parse(io, curr, line, callback)
              curr[:children][m.name] << _child
            end
          else # se a linha nao eh de nenhum dos filhos 
            if parent
              parent.reject_line(line)
              return curr
            else
              raise "ParseError on line #{io.lineno}:#{line.strip[0,15]}..., no model match!"
            end
          end
          line = rejected_line

          break unless line

        end
      end

      callback ? nil : curr  # soh retorna algo se nao tiver proc
    end

    def reject_line(line)
      @rejected = line
    end

    def rejected_line
      _r , @rejected = @rejected, nil
      _r 
    end

    def match?(line)
      @matcher =~ line and true
    end
  end


  class Field
    attr_accessor :name, :range, :options, :handler, :model
    def initialize(field_name, range, model, handler = nil) 
      @first_char_number = 0
      real_range = range_from(range, model)
      @name, @range, @handler, @model = field_name, real_range, handler, model
      raise "Invalid range for #{name}: #{real_range}"  if  real_range.nil? or (real_range.last - real_range.first) < 1 
    end

    def range_from(range_or_size, model)
      if range_or_size.is_a? Fixnum
        return (model.acc_length)..(model.acc_length + range_or_size)
      elsif range_or_size.is_a? Range
        return range_or_size
      else
        raise "Unexpected type for range or size of field: '#{range_or_size.class}'"
      end
    end

    def length
      @range.length
    end

    def get_value(line)
      _range =  (range.first - (first_char_at))...(range.last - (first_char_at))
      v = line[_range]
      call_handler(v)
    end

    def first_char_at
      @_fcs ||= @model.first_char
    end


    def get_real_handler
      return nil unless  @handler 

      hd =if @handler.is_a? Symbol
        @model.get_handler(@handler)
      elsif @handler.is_a? Proc
        @handler	
      end


      raise "Invalid handler :'#{@handler}' for #{self}" unless hd
      hd
    end

    def call_handler(value)
      handler = get_real_handler
      handler ? handler.call(value) : value
    end

  end

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


