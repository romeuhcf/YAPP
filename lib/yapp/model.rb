require 'yapp/field'
module YAPP
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

end
