require 'active_support/hash_with_indifferent_access'
module YAPP

  class Model
    module Parsing
      attr_reader :rejected_line
      def parse_fields(line)
        line.chomp!
        line = line_pre_handler.call(line) if line_pre_handler
        f = ActiveSupport::HashWithIndifferentAccess.new
        fields.each do |name, field|
          f[name] = field.get_value(line)
        end

        fields.each do |name, field|
          f[name] = field.format(f[name], f)
        end
        f
      end
 
      def get_handler(handler_sym)
        formatters[handler_sym] || (parent ? parent.get_handler(handler_sym) : nil )
      end

      def spell(event, io, callback, line = nil)
          fields = line ? parse_fields(line)  : nil
          callback.call(event, self, fields, line, io.lineno) if callback
      end

      def parse(io, forwarded_line = nil, generator = nil, callback)
 
         if match?(line=forwarded_line)
           spell(:open, io, callback, line)
         end

         child_rejected_line = nil

         while line = child_rejected_line || io.gets
           line.strip!
           child_rejected_line = nil
           if sub_model = children.values.find{|c| c.match? line }
             sub_model.parse(io, line, generator, callback)
             child_rejected_line = sub_model.rejected_line
             next
           end

           reject_line(line)
           break
         end
         spell(:close, io, callback)
      end
 
      def reject_line(line)
        @rejected_line = line
      end
 
      def rejected_line
        _r , @rejected_line = @rejected_line, nil
        _r 
      end
 
      def match?(line)
        matcher =~ line and true
      end
    end  # parsing module
  end
end
