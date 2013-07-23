require 'yapp/generators/hash'
module YAPP

  class Model
    module Parsing
      def parse_fields(line)
        line.chomp!
        line = line_pre_handler.call(line) if line_pre_handler
        f = {}
        fields.each do |name, field|
          f[name] = field.get_value(line)
        end
        f
      end
 
      def get_handler(handler_sym)
        formatters[handler_sym] || (parent ? parent.get_handler(handler_sym) : nil )
      end

      def parse(io, parent_node, my_line = nil, generator = nil, callback = nil)
        @generator = generator || @generator || Generators::Hash.new

        curr = nil
        if my_line
          fields = parse_fields(my_line)
          curr = @generator.create_node(name, parent_node, my_line, io.lineno)
          @generator.add_fields(curr, fields)
        else
          curr = @generator.create_root
        end
 
        callback.call(curr) if callback

        io.each_line do |line|
          next if line.strip.size == 0 # XXX...should not do this in strict mode
 
          loop do
            if m = children.values.find{|c| c.match? line }
              if _child = m.parse(io, curr, line, generator, callback)
                @generator.add_child(curr,  m.name, _child)
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
        matcher =~ line and true
      end
    end  # parsing module
  end
end
