module YAPP
  class Model
    module Definition
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
        field = Field.new(field_name, range, self, handler_sym_or_proc)
        @fields[field.name]=field
        @acc_length += field.length
      end
 
      def formatter(formatter_sym, &block)
        @formatters[formatter_sym] = block;
      end
    end
  end
end
