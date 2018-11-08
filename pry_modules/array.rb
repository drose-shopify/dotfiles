# frozen_string_literal: true
class ArrayUtils
  def self.duplicates(array, min=2)
    h = Hash.new( 0 )
    array.each { |i|
      h[i] += 1
    }
    h.delete_if{|_,v| v < min}.keys
  end
end

class Array
  def self.toy(n=10, &block)
    block_given? ? Array.new(n,&block) : Array.new(n) {|i| i+1}
  end

unless Array.instance_methods(true).include?(:duplicates)
  def duplicates(min=2)
    ArrayUtils.duplicates(self, min)
  end
end
end