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


