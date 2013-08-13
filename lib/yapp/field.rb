module YAPP 
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
    end

    def first_char_at
      @_fcs ||= @model.first_char
    end


    def get_real_handler
      hd = @model.get_handler(:default) unless @handler
     
      hd ||= if @handler.is_a? Symbol
        @model.get_handler(@handler)
      elsif @handler.is_a? Proc
        @handler	
      end


      raise "Invalid handler :'#{@handler}' for #{self}" unless hd
      hd
    end

    def format(value, data_row)
      handler = get_real_handler
      if handler
        if handler.arity >= 2
          handler.call(value, data_row)
        else
          handler.call(value)
        end
      else 
        value
      end
    end

  end

end
